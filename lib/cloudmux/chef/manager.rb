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

require 'cloudmux/chef/client'
require 'cloudmux/chef/cookbook'
require 'cloudmux/chef/repo'
require 'cloudmux/chef/continuous_integration'
require 'cloudmux/chef/validator'

module CloudMux
  module Chef
    class Manager
      def initialize(chef_data_model)
        @model = chef_data_model
      end

      def branch
        @model.branch
      end

      def server_client
        @server_client ||= CloudMux::Chef::Client.new(@model)
      end

      def repo
        @repo ||= CloudMux::Chef::Repo.new(
          @model.source_control_repositories.first,
          branch,
          cookbook_paths: @model.source_control_paths)
      end

      def ci_client
        return @ci_client unless @ci_client.nil?
        @ci_client = CloudMux::Chef::ContinuousIntegration.new(
          @model.continuous_integration_servers.first
          )
        @ci_client.chef_repo = repo
        @ci_client
      end

      def update_status
        states = CloudMux::Chef::Validator.refresh_all(repo, server_client, ci_client)
        states.each do |cookbook, status|
          @model.cookbooks.delete_all
          update_single(cookbook, status)
        end
      end

      def generate_all_jobs
        ci_client.generate_all_jobs
      end

      private

      def has_ci_presence?(return_status)
        ci_tests = return_status.find { |type, status| type =~ /rspec/ }
        !ci_tests.nil?
      end

      def update_single(name, status)
        ci_presence = has_ci_presence?(status)
        @model.cookbooks << Cookbook.new(
          name: name,
          ci_presence: ci_presence,
          community: false,
          status: status)
      end
    end
  end
end
