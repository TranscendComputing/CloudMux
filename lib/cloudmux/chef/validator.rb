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

module CloudMux
  module Chef
    module Validator

      def self.refresh_all(chef_repo, chef_client, chef_ci)
        sync_status = check_repo_sync(chef_repo, chef_client)
        ci_status = chef_ci.get_all_states
        current_states = {}
        all_cookbooks = (sync_status.keys | ci_status.keys).sort
        all_cookbooks.each do |cookbook|
          current_states[cookbook] = {}
          current_states[cookbook].merge!(ci_status[cookbook]) unless ci_status[cookbook].nil?
          current_states[cookbook].merge!(sync_status[cookbook]) unless sync_status[cookbook].nil?
        end
        current_states
      end

      def self.check_repo_sync(chef_repo, chef_client)
        sync_status = {}
        chef_client.cookbook_names_and_versions.each do |name, versions|
          repo_obj = chef_repo.cookbook_object(name)
          if repo_obj.nil?
            sync_status[name] = { 'sync' => 'NOT_FOUND_IN_REPO' }
          else
            if !versions.include? repo_obj.version
              sync_status[name] = { 'sync' => 'VERSION_NOT_FOUND_IN_REPO' }
            else
              server_obj = chef_client.cookbook_object(name, repo_obj.version)
              if server_obj.manifest == repo_obj.manifest
                sync_status[name] = { 'sync' => 'IN_SYNC' }
              else
                sync_status[name] = { 'sync' => 'OUT_OF_SYNC' }
              end
            end
          end
        end
        chef_repo.remove_local_repo
        sync_status
      end
      
    end
  end
end
