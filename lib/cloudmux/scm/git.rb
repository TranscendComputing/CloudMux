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

require 'git'

module CloudMux
  module SCM
    class Git

      attr_accessor :url
      attr_accessor :branch
      attr_accessor :repo_name
      attr_accessor :scm_paths

      def initialize(args)
        @url   = args[:url]
        @branch    = args[:branch]
        @repo_name = args[:repo_name]
        @scm_paths = args[:scm_paths]
      end

      def cleanup
        FileUtils.rm_rf(tmp_dir)
      end

      def dir
        repo.dir.to_s
      end

      def repo
        File.exists?("#{tmp_dir}/#{@repo_name}") ? open : checkout
      end

      private

      def tmp_dir
        @dir ||= Dir.mktmpdir
      end

      def checkout
        obj = ::Git.clone(@url, @repo_name, path: tmp_dir)
        obj.checkout(@branch)
        obj
      end

      def open
        ::Git.open("#{tmp_dir}/#{@repo_name}")
      end

    end
  end
end
