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
      def self.refresh_status(args)
        cookbook_model = args[:data_model]
        repo = args[:repo]
        server_client = args[:server_client]
        ci_status = args[:ci_client].all_build_job_states(cookbook_model.name)
        sync_status = check_repo_sync(cookbook_model.name, repo, server_client)
        cookbook_model.status.merge!(args[:ci_client].new_cookbook_status)
        cookbook_model.status = ci_status.merge(sync_status)
        cookbook_model.save!
      end

      def self.check_repo_sync(name, chef_repo, chef_client)
        repo_obj = chef_repo.cookbook_object(name)
        if repo_obj.nil?
          sync_status = { 'sync' => 'NOT_FOUND_IN_REPO' }
        else
          if !chef_client.cookbook_versions(name).include? repo_obj.version
            sync_status = { 'sync' => 'VERSION_NOT_FOUND_IN_REPO' }
          else
            server_obj = chef_client.cookbook_object(name, repo_obj.version)
            if server_obj.manifest == repo_obj.manifest
              sync_status = { 'sync' => 'IN_SYNC' }
            else
              sync_status = { 'sync' => 'OUT_OF_SYNC' }
            end
          end
        end
        chef_repo.remove_local_repo
        sync_status
      end
    end
  end
end
