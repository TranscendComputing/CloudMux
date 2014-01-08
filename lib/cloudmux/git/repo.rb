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
  module Git
    class Repo

      attr_accessor :url
      attr_accessor :branch
      attr_accessor :name

      def initialize(data_model, branch='master', args = {})
        @url   = data_model.url
        @branch = branch
        @name = data_model.name
        post_initialize(args)
      end

      def post_initialize(args)
        nil
      end

      def remove_local_repo
        current_dir = checkout_dir
        @checkout_dir = nil
        FileUtils.rm_rf(current_dir)
      end

      def dir
        repo
        repo.dir.to_s
      end

      private

      def repo
        Dir["#{checkout_dir}/*"].empty? ? checkout : open
      end

      def checkout_dir
        @checkout_dir ||= Dir.mktmpdir
      end

      def checkout
        obj = ::Git.clone(@url, @name, path: checkout_dir)
        obj.checkout(@branch)
        obj
      end

      def open
        ::Git.open("#{checkout_dir}/#{@name}")
      end

    end
  end
end
