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
require 'logger'

module CloudMux
  module Jenkins
    # Jenkins api client interface
    class Client
      def initialize(data_model)
        args = { server_url: data_model.url }
        unless data_model.username.nil?
          args.merge(
            username: data_model.username,
            password: data_model.password
            )
        end
        @client = JenkinsApi::Client.new(args)
        @client.logger.level = Logger.const_get 'ERROR'
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
      end

      def list_jobs(test_type)
        @client.job.list(test_type).map { |j| @client.job.list_details(j) }
      end

      def get_suite(job_name, build = 0)
        return empty_status unless non_empty_job?(job_name)
        results = @client.job.get_build_details(job_name, build)
        timestamp = Time.at(results['timestamp'] / 1000).to_datetime
        status = {}
        tests = @client.job.get_test_results(job_name, build)
        status.merge!(suite_status(tests)) unless tests.nil?
        status.merge('timestamp' => timestamp.to_s)
      end

      def get_status(job_name, build = 0)
        return empty_status unless non_empty_job?(job_name)
        results = @client.job.get_build_details(job_name, build)
        timestamp = Time.at(results['timestamp'] / 1000).to_datetime
        status = { 'status' => results['result'] }
        status.merge('timestamp' => timestamp.to_s)
      end

      def save_job(job_name, xml_config)
        @client.job.create_or_update(job_name, xml_config)
      end

      def delete_job(name)
        @client.job.delete(job_name)
      end

      def build_job(job_name)
        @client.job.build(job_name)
      end

      def job_template(path, vars = {})
        job_template = File.join(File.dirname(__FILE__), 'jobs', "#{path}.erb")
        content      = File.read(job_template)
        Erubis::Eruby.new(content).result(vars)
      end

      private

      def empty_status
        { 'status' => 'NONE', 'timestamp' => 'N/A' }
      end

      def non_empty_job?(name)
        @client.job.exists?(name) && !@client.job.get_builds(name).empty?
      end

      def suite_status(tests)
        h = tests['suites'].map do |t|
          s = t['cases'].find { |test| test['status'] != 'PASSED' }
          formatted_status = s.nil? ? 'PASSED' : 'FAILURE'
          [t['name'], formatted_status]
        end
        Hash[h]
      end
    end
  end
end
