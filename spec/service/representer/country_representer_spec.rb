require 'service_spec_helper'

describe CategoryRepresenter do

  before :each do
    @country = FactoryGirl.build(:country)
  end

  describe "#to_json" do
    it "should export to json" do
      @country.extend(CountryRepresenter)
      result = @country.to_json
      result.should eq("{\"country\":{\"code\":\"#{@country.code}\",\"name\":\"#{@country.name}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"country\":{\"code\":\"#{@country.code}\",\"name\":\"#{@country.name}\"}}"
      new_country = Country.new
      new_country.extend(CountryRepresenter)
      new_country.from_json(json)
      new_country.name.should eq(@country.name)
      new_country.code.should eq(@country.code)
    end
  end
end
