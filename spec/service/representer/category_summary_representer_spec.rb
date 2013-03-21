require 'service_spec_helper'

describe CategorySummaryRepresenter do

  before :each do
    @category = FactoryGirl.build(:category)
    @category.set_permalink # force it to be calc'ed, without saving it
  end

  describe "#to_json" do
    it "should export to json" do
      @category.extend(CategorySummaryRepresenter)
      result = @category.to_json
      result.should eq("{\"id\":\"#{@category.id}\",\"name\":\"#{@category.name}\",\"permalink\":\"#{@category.permalink}\"}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"id\":\"#{@category.id}\",\"name\":\"#{@category.name}\",\"permalink\":\"#{@category.permalink}\"}"
      new_category = Category.new
      new_category.extend(CategorySummaryRepresenter)
      new_category.from_json(json)
      new_category.name.should eq(@category.name)
      new_category.permalink.should eq(@category.permalink)
      new_category.id.should eq(@category.id)
    end
  end
end
