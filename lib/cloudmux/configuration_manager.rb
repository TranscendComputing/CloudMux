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
  module ConfigurationManager

    def self.new(data_model)
      data_model = data_model.dup
      type = data_model.type.to_sym

      case type
      when :chef
        require 'cloudmux/chef/manager'
        CloudMux::Chef::Manager.new(data_model)
      else
        raise ArgumentError.new("#{type} is not a supported configuration manager")
      end
    end

  end
end
