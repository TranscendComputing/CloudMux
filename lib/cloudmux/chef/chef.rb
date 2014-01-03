#
# (c) Copyright 2012-2013 Transcend Computing, Inc.
#
# Licensed under the Apache License, Version 2.0 (the License);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'ridley'
require File.join(File.dirname(__FILE__), '..', 'scm', 'git')
require File.join(File.dirname(__FILE__), '..', 'ci', 'jenkins')

module CloudMux
  module ConfigurationManager
    class Chef

      attr_accessor :url, :client_name, :client_key

      attr_reader :server_client
      attr_reader :ci_client
      attr_reader :repo_client

      DEPLOY_CONFIG = "#{File.dirname(__FILE__)}/configs/deploy_config.yml"

      def initialize(url, client_name, client_key, connections = {})
        @url = url
        @client_name = client_name
        @client_key = client_key
        Ridley::Logging.logger.level = Logger.const_get 'ERROR'
        @server_client = Ridley.new(
          server_url: url,
          client_name: client_name,
          client_key: client_key)
        @ci_client = CloudMux::CI::Jenkins.new(connections[:jenkins_server])
        @repo_client = CloudMux::SCM::Git.new(
          url: connections[:scm_url],
          branch: connections[:scm_branch],
          repo_name: connections[:repo_name],
          scm_paths: connections[:scm_paths])
      end

      def check_repo_sync(component_name, version = 'latest')
        server_copy_path = download_cookbook(component_name, version)
        FileUtils.cp("#{File.dirname(__FILE__)}/configs/chefignore", server_copy_path)
        server_cookbook = Ridley::Chef::Cookbook.from_path(server_copy_path)
        chef_repo_path = find_cookbook_path(component_name, true)
        FileUtils.cp("#{File.dirname(__FILE__)}/configs/chefignore", chef_repo_path)
        chef_repo_cookbook = Ridley::Chef::Cookbook.from_path(chef_repo_path)
        chef_repo_cookbook.manifest == server_cookbook.manifest
      end

      def create_build_job(cookbook_name)
        cb_path = find_cookbook_path(cookbook_name)
        job_name = get_job_name(cookbook_name, 'build')
        job_config = base_job_config.merge(
          path: cb_path, scm_url: @repo_client.url, name: cookbook_name
          )
        job_template = File.join('chef', 'build')
        @ci_client.save_job(job_name, job_template, job_config)
      end

      def create_deploy_job(cookbook_name, driver, platform)
        job_config = base_job_config
        cb_path = find_cookbook_path(cookbook_name)
        job_name = get_job_name(cookbook_name, "#{driver}_#{platform}")
        job_template = File.join('chef', 'kitchen')
        job_config[:path] = cb_path
        job_config[:app_endpoint] = '${JENKINS_URL}'
        @ci_client.save_job(job_name, job_template, job_config)
      end

      def generate_all_build_jobs
        repo_cookbooks.each do |cb_name|
          create_build_job(cb_name)
        end
      end

      def generate_all_deploy_jobs
        deployers_config['driver_plugins'].each do |driver, platforms|
          platforms.each do |platform, config|
            repo_cookbooks.each do |cb_name|
              create_deploy_job(cb_name, driver, platform)
            end
          end
        end
      end

      # job_name needs to be of format:
      #   'cookbook__branch__driver_platform__chef'
      def generate_deploy_suites(job_name, deploy_config = nil)
        info                = job_name.split('__')
        cookbook_name, test = info[0], info[2].split('_')
        driver, platform    = test[0], test[1]
        if deploy_config.nil?
          kitchen_obj = generate_default_deploy_obj(cookbook_name)
        else
          kitchen_obj = YAML.load(deploy_config)
        end
        driver_cfg = deployers_config['driver_plugins'][driver][platform]
        kitchen_obj['suites'].each do |suite|
          suite['driver'] = { 'name' => driver }
          suite['platforms'] = [{ 'name' => platform, 'driver_config' => driver_cfg }]
        end
        kitchen_obj.to_yaml
      end

      def get_build_status
        results = []
        repo_cookbooks.each do |cb_name|
          cookbook_status = {}
          build_job = get_job_name(cb_name, 'build')
          cookbook_status['rspec'] = @ci_client.get_status(build_job, 'rspec')
          cookbook_status['foodcritic'] = @ci_client.get_status(build_job, 'foodcritic')
          cookbook_status['syntax'] = @ci_client.get_status(build_job, 'knife')
          deployers_config['driver_plugins'].each do |driver, platforms|
            platforms.each do |platform, config|
              deploy_job = get_job_name(cb_name, "#{driver}_#{platform}")
              cookbook_status["#{driver}_#{platform}_results"] = @ci_client.get_status(deploy_job, "#{driver}_#{platform}")
            end
          end
          results << { name: cb_name, results: cookbook_status }
        end
        results
      end

      def build_all
        repo_cookbooks.each do |cb_name|
          build_job_name = get_job_name(cb_name, 'build')
          @ci_client.build_job(build_job_name)
          deployers_config['driver_plugins'].each do |driver, platforms|
            platforms.each do |platform, config|
              deploy_job = get_job_name(cb_name, "#{driver}_#{platform}")
              @ci_client.build_job(deploy_job)
            end
          end
        end
      end

      def cleanup
        @repo_client.cleanup
        FileUtils.rm_rf(tmp_dir)
      end

      private

      def deployers_config
        @deploy_config ||= YAML.load_file DEPLOY_CONFIG
      end

      def base_job_config
        { scm_url: @repo_client.url, branch: @repo_client.branch }
      end

      def download_cookbook(name, version = 'latest')
        dir = "#{tmp_dir}/#{name}-#{version}"
        Dir.mkdir(dir)
        @server_client.cookbook.download(name, version, dir)
      end

      def download_all_cookbooks
        @server_client.cookbook.all.each do |name, versions|
          download_cookbook(name, 'latest')
        end
      end

      def generate_default_deploy_obj(cookbook_name)
        { 'suites' => [
            'name' => 'default',
            'provisioner' => { 'name' => 'chef_solo' },
            'run_list' => ["recipe[#{cookbook_name}]"],
            'attributes' => {}
          ]
        }
      end

      def repo_cookbooks
        paths = []
        Dir.chdir(@repo_client.dir) do
          @repo_client.scm_paths.each do |scm_path|
            paths.concat(Dir.glob("#{scm_path}/*"))
          end
        end
        paths.map { |path| File.basename(path) }
      end

      def find_cookbook_path(name, local = false)
        @repo_client.scm_paths.each do |path|
          local_scm_dir = File.join(@repo_client.dir, path)
          unless Dir["#{local_scm_dir}/*"].find { |d| name == File.basename(d) }.nil?
            if local
              return File.join(local_scm_dir, name)
            else
              return File.join(path, name)
            end
          end
        end
      end

      def get_job_name(cookbook, job_type)
        [cookbook, @repo_client.branch, job_type, 'chef'].join('__')
      end

      def tmp_dir
        @dir ||= Dir.mktmpdir
      end      
    end
  end
end
