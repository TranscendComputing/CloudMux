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
require File.join(File.dirname(__FILE__), '..', 'cloudmux', 'scm', 'git.rb')
require File.join(File.dirname(__FILE__), '..', 'cloudmux', 'ci', 'jenkins.rb')

module CloudMux
  module Chef
    class Client
      def initialize(url, client_name, key, connections)
        @chef_server = Ridley.new(
          server_url: url,
          client_name: client_name,
          client_key: key)
        @ci_client = CloudMux::CI::Jenkins.new(connections[:jenkins_server])
        @chef_repo = CloudMux::SCM::Git.new(
          url: connections[:scm_url],
          branch: connections[:scm_branch],
          repo_name: connections[:repo_name],
          scm_paths: connections[:scm_paths])
      end

      def base_job_config
        { scm_url: @chef_repo.url, branch: @chef_repo.branch }
      end

      def download_cookbook(name, version = 'latest')
        dir = Dir.mkdir("#{tmp_dir}/#{name}-#{version}")
        @chef_server.cookbook.download(name, version, dir)
      end

      def download_all_cookbooks
        @chef_server.cookbook.all.each do |name, versions|
          download_cookbook(name, 'latest')
        end
      end

      def check_cookbook_sync(cookbook_name, version)
        server_copy_path = download_cookbook(cookbook_name, version)
        chef_repo_path = find_cookbook_path(cookbook_name)
        `diff -r #{server_copy_path} #{chef_repo_path}`
      end

      def generate_all_build_jobs
        repo_cookbooks.each do |cb|
          create_build_job(cb)
        end
      end

      def generate_all_kitchen_jobs(driver, platform)
        repo_cookbooks.each do |cb|
          create_kitchen_job(cb, driver, platform)
        end
      end

      def create_build_job(cookbook_name)
        cb_path = find_cookbook_path(cookbook_name)
        job_name = get_job_name(cookbook_name, 'build')
        job_config = base_job_config.merge(
          path: cb_path, scm_url: @chef_repo.url, name: cookbook_name
          )
        job_template = File.join('chef', 'build')
        @ci_client.save_job(job_name, job_template, job_config)
      end

      def create_kitchen_job(cookbook_name, driver, platform)
        job_config = base_job_config
        cb_path = find_cookbook_path(cookbook_name)
        job_name = get_job_name(cookbook_name, "#{driver}_#{platform}")
        job_template = File.join('chef', 'kitchen')
        job_config[:path] = cb_path
        job_config[:app_endpoint] = '${JENKINS_URL}'
        @ci_client.save_job(job_name, job_template, job_config)
      end

      # job_name needs to be of format:
      #   'cookbook__branch__driver_platform__chef'
      def generate_kitchen_suites(job_name, kitchen_config = nil)
        info                = job_name.split('__')
        cookbook_name, test = info[0], info[2].split('_')
        driver, platform    = test[0], test[1]
        if kitchen_config.nil?
          kitchen_obj = generate_default_kitchen_obj(cookbook_name)
        else
          kitchen_obj = YAML.load(kitchen_config)
        end
        kitchen_obj['suites'].each do |suite|
          suite['driver'] = { 'name' => driver }
          suite['platforms'] = [{ 'name' => platform }]
        end.to_yaml
      end

      def cleanup
        @chef_repo.cleanup
        FileUtils.rm_rf(tmp_dir)
      end

      def tmp_dir
        @dir ||= Dir.mktmpdir
      end

      private

      def generate_default_kitchen_obj(cookbook_name)
        { suites: [
            name: 'default',
            provisioner: { name: 'chef_solo' },
            run_list: ["recipe[#{cookbook_name}]"],
            attributes: {}
          ]
        }
      end

      def repo_cookbooks
        paths = []
        @chef_repo.scm_paths.each do |scm_path|
          paths.concat(Dir.glob("#{scm_path}/*"))
        end
        paths.map { |path| File.basename(path) }
      end

      def find_cookbook_path(name)
        @chef_repo.scm_paths.each do |path|
          unless Dir["#{path}/*"].find { |d| d == File.join(path, name) }.nil?
            return File.join(path, name)
          end
        end
      end

      def get_job_name(cookbook, job_type)
        [cookbook, @chef_repo.branch, job_type, 'chef'].join('__')
      end
    end
  end
end
