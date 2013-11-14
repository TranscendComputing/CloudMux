# test env
require 'rspec'
require 'factory_girl'

# gems required only for tests
# require 'open-uri'

# Setup the rack environment to signal test mode to all gems and configurations
ENV['RACK_ENV'] = 'test'

# require the dependencies
require File.join(File.dirname(__FILE__), '..', 'lib', 'core')

#
# Helper methods
#

def file(filename)
  File.new(filename).readlines.join("\n")
end

def create_project
  @cloud_account = FactoryGirl.build(:cloud_account)
  @owner = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
  #@owner.cloud_accounts << @cloud_account
  @owner.save
  @project = FactoryGirl.create(:project, :cloud_account=>@cloud_account, :owner=>@owner)
  @project
end
