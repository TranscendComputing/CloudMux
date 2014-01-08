require 'app_spec_helper'

require File.join(APP_DIR, 'orchestration', 'config_manager_validator_api_app')
require File.join(LIB_DIR, 'cloudmux', 'chef.rb')

include HttpStatusCodes

describe ConfigManagerValidatorApiApp do
  def app
    ConfigManagerValidatorApiApp
  end

  after :each do
    # this test uses the db storage
    #  for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  context 'valid kitchen config' do
    describe 'POST /deploy_suite' do
      before :each do
        test_kitchen = File.join(File.dirname(__FILE__), 'fixtures', 'kitchen.yml')
        post '/deploy_suite', job_name: 'name__branch__vagrant_ubuntu-12.04__chef', file: File.read(test_kitchen)
      end

      it 'should return a success response code' do
        last_response.should be_ok
      end
    end
  end

  context 'no kitchen config' do
    describe 'POST /deploy_suite' do
      before :each do
        post '/deploy_suite', job_name: 'name__branch__vagrant_ubuntu-12.04__chef'
      end

      it 'should return a success response code' do
        last_response.should be_ok
      end
    end
  end
end
