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

FactoryGirl.define do
  factory :chef_manager, :class => ConfigurationManager do |a|
    a.url 'http://localhost_chef'
    a.type 'chef'
    a.name 'test_chef'
    a.auth_properties { 'client_name' => 'tester', 'key' => 'content' }
    a.branch 'test'
    a.source_control_paths ['cookbooks/one', 'cookbooks/two']
  end

  factory :jenkins_server, :class => ContinuousIntegrationServer do |a|
    a.name 'CIServer'
    a.type 'jenkins'
    a.url 'http://localhost_jenkins:8080'
  end

  factory :git_repo, :class => SourceControlRepository do |a|
    a.name 'TestRepo'
    a.type 'git'
    a.url 'http://localhost_git'
    a.username 'tester'
    a.password 'password'
    a.key 'content'
  end
end