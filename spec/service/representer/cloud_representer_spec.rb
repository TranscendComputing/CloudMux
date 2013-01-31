require 'service_spec_helper'

describe CloudRepresenter do

  before :each do
    @cloud = FactoryGirl.build(:cloud)
    @cloud.cloud_services = FactoryGirl.build_list(:cloud_service, 2)
    @cloud.prices = FactoryGirl.build_list(:price, 2)
    @cloud.set_permalink # force it to be calc'ed, without saving it
  end

  describe "#to_json" do
    it "should export to json" do
      @cloud.extend(CloudRepresenter)
      result = @cloud.to_json
      result.should eq("{\"cloud\":{\"id\":\"#{@cloud.id}\",\"name\":\"#{@cloud.name}\",\"permalink\":\"#{@cloud.permalink}\",\"public\":true,\"topstack_enabled\":true,\"topstack_id\":\"cloud_zone\",\"prices\":[{\"price\":{\"id\":\"#{@cloud.prices[0].id}\",\"name\":\"#{@cloud.prices[0].name}\",\"type\":\"#{@cloud.prices[0].type}\",\"effective_price\":#{@cloud.prices[0].effective_price},\"effective_date\":#{@cloud.prices[0].effective_date.to_json}}},{\"price\":{\"id\":\"#{@cloud.prices[1].id}\",\"name\":\"#{@cloud.prices[1].name}\",\"type\":\"#{@cloud.prices[1].type}\",\"effective_price\":#{@cloud.prices[1].effective_price},\"effective_date\":#{@cloud.prices[1].effective_date.to_json}}}],\"cloud_services\":[{\"cloud_service\":{\"id\":\"#{@cloud.cloud_services[0].id}\",\"service_type\":\"#{@cloud.cloud_services[0].service_type}\",\"path\":\"#{@cloud.cloud_services[0].path}\"}},{\"cloud_service\":{\"id\":\"#{@cloud.cloud_services[1].id}\",\"service_type\":\"#{@cloud.cloud_services[1].service_type}\",\"path\":\"#{@cloud.cloud_services[1].path}\"}}],\"cloud_mappings\":[]}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"cloud\":{\"id\":\"#{@cloud.id}\",\"name\":\"#{@cloud.name}\",\"permalink\":\"#{@cloud.permalink}\"}}"
      new_cloud = Cloud.new
      new_cloud.extend(CloudRepresenter)
      new_cloud.from_json(json)
      new_cloud.name.should eq(@cloud.name)
      new_cloud.permalink.should eq(@cloud.permalink)
      new_cloud.id.should eq(@cloud.id)
    end
  end
end
