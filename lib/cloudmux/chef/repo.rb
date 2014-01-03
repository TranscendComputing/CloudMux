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

require 'cloudmux/git/repo'
require 'ridley'

module CloudMux
  module Chef
    class Repo < CloudMux::Git::Repo
      attr_accessor :cookbook_paths

      def post_initialize(args)
        @cookbook_paths = args[:cookbook_paths]
      end

      def expanded_cookbook_paths
        return @cookbooks unless @cookbooks.nil?
        @cookbooks = []
        cookbook_paths.map do |path|
          @cookbooks.concat Dir.glob("#{dir}/#{path}/*")
        end
        @cookbooks
      end

      def find_expanded_cookbook_path(name)
        expanded_cookbook_paths.find { |path| File.basename(path) == name }
      end

      def find_relative_cookbook_path(name)
        expanded_path = find_expanded_cookbook_path(name).dup
        expanded_path.slice! "#{dir}/"
        File.dirname expanded_path
      end

      def cookbook_names
        @cookbook_names ||=
          expanded_cookbook_paths.map { |path| File.basename(path) }
      end

      def cookbook_objects
        @cookbook_objects ||=
        expanded_cookbook_paths.map do |path|
          load_from(path)
        end
      end

      def cookbook_object(name)
        path = find_expanded_cookbook_path(name)
        path.nil? ? nil : load_from(path)
      end

      def remove_local_repo
        @cookbooks = nil
        @cookbook_names = nil
        @cookbook_objects = nil
        super
      end      

      private

      def load_from(path)
        FileUtils.cp("#{File.dirname(__FILE__)}/configs/chefignore", path)
        Ridley::Chef::Cookbook.from_path path
      end

    end
  end
end
