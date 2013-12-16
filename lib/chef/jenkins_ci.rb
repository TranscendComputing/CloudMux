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

require 'jenkins_api_client'
require 'erubis'
require 'git'
require 'pry'

module Chef
  class JenkinsCI
    def initialize(jenkins_ip, args = {})
      @scm_url   = args[:scm_url]
      @branch    = args[:branch]
      @repo_name = args[:repo_name]
      @scm_paths = args[:scm_paths]
      @client = JenkinsApi::Client.new(args.merge(server_ip: jenkins_ip))
    end

    def list_jobs(test_type)
      @client.job.list(test_type).map { |j| @client.job.list_details(j) }
    end

    # ===Arguments
    # config[:test]::: Test to create job for
    # config[:tool]::: Framework of tool
    # config[:path]::: Cookbook directory within repo
    def save_job(name, config = {})
      test      = config[:test]
      tool      = config[:tool]
      job_name  = "#{name}__#{@branch}__#{test}__#{tool}"
      tmpl_vars = config.merge(scm_url: @scm_url, branch: @branch, name: name)
      tmpl      = config[:tmpl] || config[:test]
      job_template = File.join(File.dirname(__FILE__), 'jobs', "#{tmpl}.erb")
      content      = File.read(job_template)
      xml          = Erubis::Eruby.new(content).result(tmpl_vars)

      @client.job.create_or_update(job_name, xml)
    end

    def delete_job(name, test, tool)
      job_name = "#{name}__#{@branch}__#{test}__#{tool}"
      @client.job.delete(job_name)
    end

    def create_jobs
      dir  = Dir.mktmpdir
      checkout(dir)
      cookbooks = get_cookbook_info_from_repo
      cookbooks.each do |info|
        cfg = { path: info[:path], tool: 'chef' }
        build_cfg = cfg.merge(test: 'build')
        save_job(info[:name], build_cfg)
        k_cfg = cfg.merge(test: 'vagrant_ubuntu-12.04', tmpl: 'kitchen', app_endpoint: '${JENKINS_URL}')
        save_job(info[:name], k_cfg)
      end
      FileUtils.rm_rf(dir)
    end

    def generate_kitchen_suites(job_name, kitchen_config = nil)
      # Name is cookbook__branch__driver-platform__chef
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

    private

    def checkout(dir = Dir.mktmpdir)
      @repo = Git.clone(@scm_url, @repo_name, path: dir)
      @repo.checkout(@branch)
    end

    def get_cookbook_info_from_repo
      cookbooks = []
      @repo.chdir do
        @scm_paths.each do |path|
          cb_dirs = Dir.glob("#{path}/*")
          cb_info = cb_dirs.map { |p| { name: File.basename(p), path: p } }
          cookbooks.concat(cb_info)
        end
      end
      cookbooks
    end

    def generate_default_kitchen_obj(cookbook_name)
      { suites: [
          name: 'default',
          provisioner: { name: 'chef_solo' },
          run_list: ["recipe[#{cookbook_name}]"],
          attributes: {}
        ]
      }
    end
  end
end
