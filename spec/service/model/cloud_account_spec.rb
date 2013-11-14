require 'service_spec_helper'

describe CloudAccount do
  before :each do
    @cloud_account = FactoryGirl.build(:cloud_account)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

end
