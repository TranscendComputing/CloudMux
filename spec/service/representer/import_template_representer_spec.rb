require 'service_spec_helper'

describe ImportTemplateRepresenter do

  before :each do
    @import = ImportTemplate.new
  end

  describe "#to_json" do
    it "should export import_source to json" do
      url = "http://test.test/fake/url"
      @import.import_source = url
      @import.extend(ImportTemplateRepresenter)
      result = @import.to_json
      result.should eq("{\"import_source\":\"#{url}\"}")
    end

    it "should export json to base64" do
      json = "{\"test1\":\"value1\", \"test2\":\"value2\"}"
      expected = "{\\\"test1\\\":\\\"value1\\\", \\\"test2\\\":\\\"value2\\\"}\""
      @import.json = json
      @import.extend(ImportTemplateRepresenter)
      result = @import.to_json
      result.should eq("{\"json_base64\":\"eyJ0ZXN0MSI6InZhbHVlMSIsICJ0ZXN0MiI6InZhbHVlMiJ9\\n\"}")
    end
  end

  describe "#from_json" do
    it "should import import_source from json payload" do
      url = "http://test.test/fake/url"
      json = "{\"import_source\":\"#{url}\"}"
      @import.extend(ImportTemplateRepresenter)
      @import.from_json(json)
      @import.import_source.should eq(url)
      @import.json.should eq(nil)
    end

    it "should parse json from json base64 payload" do
      json = "{\"json_base64\":\"eyJ0ZXN0MSI6InZhbHVlMSIsICJ0ZXN0MiI6InZhbHVlMiJ9\\n\"}"
      expected = "{\"test1\":\"value1\", \"test2\":\"value2\"}"
      @import.extend(ImportTemplateRepresenter)
      @import.from_json(json)
      @import.import_source.should eq(nil)
      @import.json.should eq(expected)
    end
  end
end
