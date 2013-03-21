require 'service_spec_helper'

describe QueryRepresenter do

  before :each do
    @query = FactoryGirl.build(:query)
  end

  describe "#to_json" do
    it "should export to json" do
      @query.extend(QueryRepresenter)
      result = @query.to_json
      result.should eq("{\"total\":#{@query.total},\"page\":#{@query.page},\"offset\":#{@query.offset},\"links\":[]}")
    end

    it "should export to json with links" do
      @query.extend(QueryRepresenter)
      @query.links << Link.new("test", "http://test.test/test")
      result = @query.to_json
      result.should eq("{\"total\":#{@query.total},\"page\":#{@query.page},\"offset\":#{@query.offset},\"links\":[{\"rel\":\"test\",\"href\":\"http://test.test/test\"}]}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"total\":#{@query.total},\"page\":#{@query.page},\"offset\":#{@query.offset}}"
      new_query = Query.new
      new_query.extend(QueryRepresenter)
      new_query.from_json(json)
      new_query.total.should eq(@query.total)
      new_query.page.should eq(@query.page)
      new_query.offset.should eq(@query.offset)
      new_query.links.length.should eq(0)
    end

    it "should import from json payload with links" do
      json = "{\"total\":#{@query.total},\"page\":#{@query.page},\"offset\":#{@query.offset},\"links\":[{\"rel\":\"test\",\"href\":\"http://test.test/test\"}]}"
      new_query = Query.new
      new_query.extend(QueryRepresenter)
      new_query.from_json(json)
      new_query.total.should eq(@query.total)
      new_query.page.should eq(@query.page)
      new_query.offset.should eq(@query.offset)
      new_query.links.length.should eq(1)
      new_query.links[0].rel.should eq("test")
    end
  end
end
