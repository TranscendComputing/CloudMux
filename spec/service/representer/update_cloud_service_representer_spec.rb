require 'service_spec_helper'

describe UpdateCloudServiceRepresenter do

  before :each do
    @cloud_service = FactoryGirl.build(:cloud_service)
  end

  describe "#to_json" do
    it "should export to json" do
      @cloud_service.extend(UpdateCloudServiceRepresenter)
      result = @cloud_service.to_json
      result.should eq("{\"cloud_service\":{\"service_type\":\"#{@cloud_service.service_type}\",\"path\":\"#{@cloud_service.path}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"cloud_service\":{\"service_type\":\"#{@cloud_service.service_type}\",\"path\":\"#{@cloud_service.path}\"}}"
      new_cloud_service = CloudService.new
      new_cloud_service.extend(UpdateCloudServiceRepresenter)
      new_cloud_service.from_json(json)
      new_cloud_service.service_type.should eq(@cloud_service.service_type)
      new_cloud_service.path.should eq(@cloud_service.path)
    end
  end
end
