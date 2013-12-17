require 'service_spec_helper'

describe OrgRepresenter do

  before :each do
    @org = FactoryGirl.build(:org)
  end

  describe "#to_json" do
    it "should export to json" do
      @org.extend(OrgRepresenter)
      result = @org.to_json
      result.should eq("{\"org\":{\"id\":\"#{@org.id}\",\"name\":\"#{@org.name}\",\"accounts\":[],\"cloud_accounts\":[],\"config_managers\":[],\"groups\":[],\"subscriptions\":[],\"cloud_mappings\":[]}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"org\":{\"id\":\"#{@org.id}\",\"name\":\"#{@org.name}\",\"subscriptions\":[],\"cloud_mappings\":[]}}"
      new_org = Org.new
      new_org.extend(OrgRepresenter)
      new_org.from_json(json)
      new_org.name.should eq(@org.name)
      new_org.id.should eq(@org.id)
    end
  end
end
