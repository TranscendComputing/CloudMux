require 'service_spec_helper'

describe CloudAccount do
  before :each do
    @cloud_account = FactoryGirl.build(:cloud_account)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#valid" do
    it "should require a name" do
      @cloud_account.valid?.should eq(true)
      @cloud_account.name = nil
      @cloud_account.valid?.should eq(false)
    end
  end
end
