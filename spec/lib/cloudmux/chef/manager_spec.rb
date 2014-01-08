require 'rspec'
require 'cloudmux/chef/manager'

describe CloudMux::Chef::Manager do

  before :each do
    @manager = FactoryGirl.build(:chef_manager)
  end

  describe '#synced_with_scm' do
    it 'takes two parameters of types CloudMux::Chef::Client, CloudMux::Git::Client and returns hash of {name: boolean}' 
  end

  describe '#create_build_jobs' do
    it 'takes two parameters of types CloudMux::Chef::Client, CloudMux::Jenkins::Client and returns boolean' 
  end

  describe '#create_deploy_jobs' do
    it 'takes two parameters of types CloudMux::Chef::Client, CloudMux::Jenkins::Client and returns boolean'
  end

end