# test env
require 'rspec'
require 'factory_girl'
require 'simplecov'
require 'coveralls'
require 'webmock/rspec'

#
# [XXX] Disabling Network Access for tests
#

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

#Coveralls.wear!

# gems required only for tests
# require 'open-uri'

# Setup the rack environment to signal test mode to all gems and configurations
ENV['RACK_ENV'] = 'test'

# require the dependencies
require File.join(File.dirname(__FILE__), '..', 'lib', 'core')
require File.join(File.dirname(__FILE__), 'support', 'fake_ansible')

WebMock.disable_net_connect! allow_localhost:true

# from http://robots.thoughtbot.com/how-to-stub-external-services-in-tests/
RSpec.configure do |config|
  config.before :each do
    stub_request(:any, /the.ansibleserver.com/).to_rack FakeAnsible
  end
end

#
# Helper methods
#

def file(filename)
  File.new(filename).readlines.join("\n")
end

def create_project
  @cloud_credential = FactoryGirl.build(:cloud_credential)
  @owner = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
  #@owner.cloud_accounts << @cloud_account
  @owner.save
  @project = FactoryGirl.create(:project, :cloud_credential=>@cloud_credential, :owner=>@owner)
  @project
end
