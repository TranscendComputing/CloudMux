require 'service_spec_helper'

describe UpdateCloudAccountRepresenter do

  before :each do
    @cloud_account = FactoryGirl.build(:cloud_account)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end  

  describe "#to_json" do
    it "should export to json" do
      @cloud_account.extend(UpdateCloudAccountRepresenter)
      result = @cloud_account.to_json
      result.should eq("{\"cloud_account\":{\"name\":\"#{@cloud_account.name}\",\"topstack_enabled\":true,\"topstack_id\":\"cloud_zone\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"cloud_account\":{\"name\":\"#{@cloud_account.name}\", \"topstack_id\":\"#{@cloud_account.topstack_id}\",\"topstack_enabled\":\"#{@cloud_account.topstack_enabled}\"}}"
      new_cloud_account = CloudAccount.new
      new_cloud_account.extend(UpdateCloudAccountRepresenter)
      new_cloud_account.from_json(json)
      new_cloud_account.name.should eq(@cloud_account.name)
      new_cloud_account.topstack_id.should eq(@cloud_account.topstack_id)
      new_cloud_account.topstack_enabled.should eq(@cloud_account.topstack_enabled)
    end
  end  
end