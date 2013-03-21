require 'service_spec_helper'

describe CountryQueryRepresenter do

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  before :each do
    @country = FactoryGirl.create(:country)
    @query = FactoryGirl.build(:query)
    @country_query = CountryQuery.new
    @country_query.query = @query
    @country_query.countries << @country
  end

  describe "#to_json" do
    it "should export to json" do
      @country_query.extend(CountryQueryRepresenter)
      result = @country_query.to_json
      result.should eq("{\"query\":{\"total\":504,\"page\":10,\"offset\":500,\"links\":[]},\"countries\":[{\"country\":{\"code\":\"#{@country.code}\",\"name\":\"#{@country.name}\"}}]}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"query\":{\"total\":504,\"page\":10,\"offset\":500,\"links\":[]},\"countries\":[{\"country\":{\"code\":\"#{@country.code}\",\"name\":\"#{@country.name}\"}}]}"
      new_country_query = CountryQuery.new
      countries = new_country_query.countries
      countries.should_not eq(nil)
      countries.length.should eq(0)
      new_country_query.extend(CountryQueryRepresenter)
      new_country_query.from_json(json)
      new_country_query.query.should_not eq(nil)
      new_country_query.query.total.should eq(@query.total)
      countries = new_country_query.countries
      countries.first.name.should eq(@country.name)
      new_country_query.query.links.length.should eq(0)
    end
  end
end
