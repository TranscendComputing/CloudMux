require 'service_spec_helper'

describe CloudRepresenter do

  before :each do
    @cloud = FactoryGirl.build(:cloud)
    @cloud.set_permalink # force it to be calc'ed, without saving it
  end

  describe "#to_json" do
    it "should export to json" do
      @cloud.extend(CloudRepresenter)
      result = @cloud.to_json
      result.should eq("{\"cloud\":{\"id\":\"#{@cloud.id}\",\"name\":\"#{@cloud.name}\",\"cloud_provider\":\"#{@cloud.cloud_provider}\",\"permalink\":\"#{@cloud.permalink}\",\"public\":true}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"cloud\":{\"id\":\"#{@cloud.id}\",\"name\":\"#{@cloud.name}\",\"cloud_provider\":\"#{@cloud.cloud_provider}\",\"permalink\":\"#{@cloud.permalink}\"}}"
      new_cloud = Cloud.new
      new_cloud.extend(CloudRepresenter)
      new_cloud.from_json(json)
      new_cloud.name.should eq(@cloud.name)
      new_cloud.permalink.should eq(@cloud.permalink)
      new_cloud.id.should eq(@cloud.id)
    end
  end
end
