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

require File.join(File.dirname(__FILE__), '..', 'ci.rb')
require File.join(File.dirname(__FILE__), 'client.rb')
require File.join(File.dirname(__FILE__), '..', 'cloudmux', 'scm', 'git.rb')
require File.join(File.dirname(__FILE__), '..', 'cloudmux', 'ci', 'jenkins.rb')

module CloudMux
  module Chef
    class CI

      def initialize(attributes)
        @git = CloudMux::SCM::Git.new(attributes)
        @ci  = CloudMux::CI::Jenkins.new(attributes[:jenkins_server])
        super(attributes)
      end

      


    end
  end
end
