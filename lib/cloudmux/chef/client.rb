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

module CloudMux
  module Chef
    class Client

      def initialize(data_model)
        url = data_model.url
        client_name = data_model.auth_properties['client_name']
        client_key = data_model.auth_properties['key']
        @connection_data = {
          server_url: url,
          client_name: client_name,
          client_key: client_key
        }
      end

      def cookbook_object(name, version = 'latest')
        if Dir["#{download_path}/*"].empty?
          download_cookbook(name, version, download_path)
        end
        cookbook = load_from(download_path)
        cleanup_local_files
        cookbook
      rescue Ridley::Errors::ResourceNotFound
        nil
      end

      def cookbook_versions(name)
        Ridley.open(@connection_data) do |conn|
          conn.cookbook.versions(name)
        end
      rescue Ridley::Errors::ResourceNotFound
        []
      end

      def cookbook_names
        @cookbook_names ||=
          Ridley.open(@connection_data) do |conn|
            conn.cookbook.all.keys
          end
      end

      def cookbook_names_and_versions
        @cookbook_names_and_versions ||=
          Ridley.open(@connection_data) do |conn|
            Hash[conn.cookbook.all.sort]
          end
      end

      private

      def cleanup_local_files
        current_path = download_path
        @download_path = nil
        FileUtils.rm_rf(current_path)
      end

      def download_path
        @download_path ||= Dir.mktmpdir
      end

      def load_from(path)
        FileUtils.cp("#{File.dirname(__FILE__)}/configs/chefignore", path)
        Ridley::Chef::Cookbook.from_path path
      end

      def download_cookbook(name, version, path)
        Ridley.open(@connection_data) do |conn|
          conn.cookbook.download(name, version, path)
        end
      end

    end
  end
end
