require 'service_spec_helper'

describe UpdateCategoryRepresenter do

  before :each do
    @category = FactoryGirl.build(:category)
    @category.set_permalink # force it to be calc'ed, without saving it
  end

  describe "#to_json" do
    it "should export to json" do
      @category.extend(UpdateCategoryRepresenter)
      result = @category.to_json
      result.should eq("{\"category\":{\"name\":\"#{@category.name}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"category\":{\"name\":\"#{@category.name}\"}}"
      new_category = Category.new
      new_category.extend(UpdateCategoryRepresenter)
      new_category.from_json(json)
      new_category.name.should eq(@category.name)
      new_category.permalink.should eq(nil)
    end
  end
end
