require 'service_spec_helper'

describe CloudMappingRepresenter do

  before :each do
    @mapping = FactoryGirl.build(:cloud_mapping)
    @mapping.properties = { "prop1"=>"value1",  "prop2"=>"value2" }
    @mapping.mapping_entries = [ { "entry1"=>"value1e",  "entry2"=>"value2e" }, { "entry3"=>"value3e",  "entry4"=>"value4e" }]
  end

  describe "#to_json" do
    it "should export to json" do
      @mapping.extend(CloudMappingRepresenter)
      result = @mapping.to_json
      result.should eq("{\"cloud_mapping\":{\"id\":\"#{@mapping.id}\",\"name\":\"My Mapping\",\"properties\":{\"prop1\":\"value1\",\"prop2\":\"value2\"},\"mapping_entries\":[{\"entry1\":\"value1e\",\"entry2\":\"value2e\"},{\"entry3\":\"value3e\",\"entry4\":\"value4e\"}]}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"cloud_mapping\":{\"id\":\"#{@mapping.id}\",\"name\":\"My Mapping\",\"properties\":{\"prop1\":\"value1\",\"prop2\":\"value2\"},\"mapping_entries\":[{\"entry1\":\"value1e\",\"entry2\":\"value2e\"},{\"entry3\":\"value3e\",\"entry4\":\"value4e\"}]}}"
      new_mapping = CloudMapping.new
      new_mapping.extend(CloudMappingRepresenter)
      new_mapping.from_json(json)
      new_mapping.name.should eq(@mapping.name)
      new_mapping.properties.length.should eq(@mapping.properties.length)
      new_mapping.mapping_entries.length.should eq(@mapping.mapping_entries.length)
    end
  end
end
