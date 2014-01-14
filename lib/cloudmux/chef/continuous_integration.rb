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

require 'cloudmux/jenkins/client'
require 'socket'

module CloudMux
  module Chef
    class ContinuousIntegration < CloudMux::Jenkins::Client
      attr_accessor :chef_repo

      DEPLOY_CONFIG = "#{File.dirname(__FILE__)}/configs/deploy_config.yml"
      BUILD_TESTS   = %w{ rspec foodcritic syntax }
      # Used for generating/referencing job names
      VERSION_SEPARATOR     = '.'
      VERSION_SEPARATOR_SUB = '--'
      NAME_SEPARATOR        = '__'
      DEPLOY_SEPARATOR      = '-'

      def delete_all_jobs
        @chef_repo.cookbook_names.each do |name|
          delete_job(name, 'build')
          deploy_jobs.each do |job|
            delete_job(name, job)
          end
        end
      end

      def delete_job(cookbook_name, type)
        job = get_job_name(name, type)
        @client.job.delete job
      rescue
        return false
      end

      def create_build_job(cookbook_name)
        @logger.debug("Creating build job for #{cookbook_name}")
        path = cookbook_path(cookbook_name)
        job_name = get_job_name(cookbook_name, 'build')
        job_config = base_job_config.merge(
          path: path, scm_url: @chef_repo.url, name: cookbook_name
          )
        template = job_template(File.join('chef', 'build'), job_config)
        save_job(job_name, template)
      end

      def create_deploy_jobs(cookbook_name)
        job_config = base_job_config
        deploy_jobs.each do |job_type|
          job_name = get_job_name(cookbook_name, job_type)
          @logger.debug("Creating #{job_name} job for #{cookbook_name}")
          job_config[:path] = cookbook_path(cookbook_name)
          ip = IPSocket.getaddress(Socket.gethostname)
          job_config[:app_endpoint] = "http://#{ip}:9292"
          template = job_template(File.join('chef', 'kitchen'), job_config)
          save_job(job_name, template)
        end
      end

      # job_name needs to be of format:
      #   'cookbook__branch__driver_platform-majorversion--minorversion__chef'
      def self.generate_deploy_suites(job_name, deploy_config = nil)
        info          = job_name.split(NAME_SEPARATOR)
        cookbook_name = info[0]
        test          = info[2].split(DEPLOY_SEPARATOR)
        driver   = test[0]
        platform = test[1].gsub(VERSION_SEPARATOR_SUB, VERSION_SEPARATOR)
        if deploy_config.nil?
          kitchen_obj = generate_default_deploy_obj(cookbook_name)
        else
          kitchen_obj = YAML.load(deploy_config)
        end
        deploy_cfg = YAML.load_file DEPLOY_CONFIG
        driver_cfg = deploy_cfg['driver_plugins'][driver][platform]
        kitchen_obj['driver'] = { 'name' => driver }
        kitchen_obj['platforms'] = [{
          'name' => platform, 'driver_config' => driver_cfg
        }]
        kitchen_obj.to_yaml
      end

      def job_status(cookbook)
        @logger.debug("Getting job status for #{cookbook}")
        build_job = get_job_name(cookbook, 'build')
        cookbook_status = default_status.dup
        cookbook_status.merge!(get_suite(build_job))
        deploy_jobs.each do |job|
          deploy_job = get_job_name(cookbook, job)
          results = get_status(deploy_job)
          cookbook_status.merge!(
            "#{job}" => results['status'],
            'timestamp' => results['timestamp']
          )
        end
        cookbook_status
      end

      def default_status
        status = Hash[BUILD_TESTS.map { |t| [t, 'NONE'] }]
        status.merge! Hash[deploy_jobs.map { |t| [t, 'NONE'] }]
        status.merge!('sync' => 'NONE', 'timestamp' => 'N/A')
      end

      private

      def deploy_jobs
        names = []
        deployers_config['driver_plugins'].each do |driver, platforms|
          platforms.each do |platform, config|
            fp = platform.gsub(VERSION_SEPARATOR, VERSION_SEPARATOR_SUB)
            names << [driver, fp].join(DEPLOY_SEPARATOR)
          end
        end
        names
      end

      def get_job_name(cookbook, job_type)
        [cookbook, @chef_repo.branch, job_type, 'chef'].join(NAME_SEPARATOR)
      end

      def cookbook_path(name)
        path = @chef_repo.find_relative_cookbook_path(name)
        File.join(path, name)
      end

      def deployers_config
        @deploy_config ||= YAML.load_file DEPLOY_CONFIG
      end

      def base_job_config
        { scm_url: @chef_repo.url, branch: @chef_repo.branch }
      end

      def self.generate_default_deploy_obj(cookbook_name)
        { 'suites' => [
            'name' => 'default',
            'provisioner' => { 'name' => 'chef_solo' },
            'run_list' => ["recipe[#{cookbook_name}]"],
            'attributes' => {}
          ]
        }
      end
    end
  end
end
