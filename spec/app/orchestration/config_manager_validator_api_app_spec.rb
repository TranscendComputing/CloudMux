require 'app_spec_helper'
require 'pry'

require File.join(APP_DIR, 'orchestration', 'config_manager_validator_api_app')
require File.join(LIB_DIR, 'cloudmux', 'chef.rb')

include HttpStatusCodes

describe ConfigManagerValidatorApiApp do
  def app
    ConfigManagerValidatorApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

end
