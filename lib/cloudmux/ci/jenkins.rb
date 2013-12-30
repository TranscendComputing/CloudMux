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
require 'pry'

module CloudMux
  module CI
    class Jenkins

      def initialize(server_ip, args = {})
        @client = JenkinsApi::Client.new(args.merge(server_url: server_ip))
        @client.logger.level = Logger.const_get 'ERROR'
        @client
      end

      def list_jobs(test_type)
        @client.job.list(test_type).map { |j| @client.job.list_details(j) }
      end

      def get_status(job_name, suite_type)
        suite = get_suite_results(job_name, suite_type)
        return 'NONE' if suite.nil?
        suite['cases'].find { |test| test['status'] != 'PASSED' }.nil? ? 'PASSING' : 'FAILING'
      end

      def save_job(job_name, template, template_vars = {})
        job_template = File.join(File.dirname(__FILE__), 'jobs', "#{template}.erb")
        content      = File.read(job_template)
        xml          = Erubis::Eruby.new(content).result(template_vars)
        @client.job.create_or_update(job_name, xml)
      end

      def delete_job(name)
        @client.job.delete(job_name)
      end

      def build_job(job_name)
        @client.job.build(job_name)
      end

      private

      def get_suite_results(job_name, suite_type)
        job_results = get_test_results(job_name)
        return nil if job_results.nil?
        job_results['suites'].find { |suite| suite['name'] =~ /#{suite_type}/ }
      end

      def get_test_results(name, build = 0)
        @client.job.get_test_results(name, build)
      end

    end
  end
end
