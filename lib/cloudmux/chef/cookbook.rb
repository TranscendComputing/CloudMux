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
    class Cookbook

      attr_reader :name, :version
      attr_writer :server_client, :chef_repo

      def initialize(name, version = 'latest')
        @name = name
        @version = version
      end

      def load_from(location)
        location = location.to_s.downcase.to_sym
        case location
        when :server
          download if Dir["#{tmp_path}/*"].empty?
          path = tmp_path
        when :repo
          path = chef_repo.find_expanded_cookbook_path(name)
        else
          raise ArgumentError "#{location} is not a known location"
        end
        if path.nil?
          return nil
        else
          FileUtils.cp("#{File.dirname(__FILE__)}/configs/chefignore", path)
          Ridley::Chef::Cookbook.from_path(path).manifest
        end
      end

      def cleanup
        File.rm_rf(File.dirname(tmp_path))
      end

      private

      def download
        @server_client.download_cookbook(@name, @version, tmp_path)
      end

      def tmp_path
        @dir ||= "#{Dir.mktmpdir}/#{@name}-#{@version}"
        Dir.mkdir(@dir) unless File.exists?(@dir)
        @dir
      end

    end
  end
end
