require 'service_spec_helper'

describe CategoryQueryRepresenter do

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  before :each do
    @category = FactoryGirl.create(:category)
    @query = FactoryGirl.build(:query)
    @category_query = CategoryQuery.new
    @category_query.query = @query
    @category_query.categories << @category
  end

  describe "#to_json" do
    it "should export to json" do
      @category_query.extend(CategoryQueryRepresenter)
      result = @category_query.to_json
      result.should eq("{\"query\":{\"total\":504,\"page\":10,\"offset\":500,\"links\":[]},\"categories\":[{\"category\":{\"id\":\"#{@category.id}\",\"name\":\"My Category\",\"permalink\":\"my-category\"}}]}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"query\":{\"total\":504,\"page\":10,\"offset\":500,\"links\":[]},\"categories\":[{\"category\":{\"id\":\"#{@category.id}\",\"name\":\"My Category\",\"permalink\":\"my-category\"}}]}"
      new_category_query = CategoryQuery.new
      categories = new_category_query.categories
      categories.should_not eq(nil)
      categories.length.should eq(0)
      new_category_query.extend(CategoryQueryRepresenter)
      new_category_query.from_json(json)
      new_category_query.query.should_not eq(nil)
      new_category_query.query.total.should eq(@query.total)
      categories = new_category_query.categories
      categories.first.name.should eq(@category.name)
      new_category_query.query.links.length.should eq(0)
    end
  end
end
