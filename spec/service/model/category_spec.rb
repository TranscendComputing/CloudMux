require 'service_spec_helper'

describe Category do
  before :each do
    @category = FactoryGirl.build(:category)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#initialize" do
    it "should initialize properly" do
      @category.should_not eq(nil)
    end
  end

  describe "#valid?" do
    it "should require properly name field" do
      @category.valid?.should eq(true)
      @category.name = nil
      @category.valid?.should eq(false)
    end
  end

  describe "#set_permalink" do
    it "should not set the permalink if one is already set" do
      @category.permalink = "mine"
      @category.save!
      @category.permalink.should eq("mine")
    end

    it "should set the permalink on save" do
      @category.save!
      @category.reload
      @category.permalink.should eq("my-category")
    end
  end

  describe "#find_by_permalink" do
    it "should find by permalink" do
      @category.save!
      @category.permalink.should_not eq(nil)
      found = Category.find_by_permalink(@category.permalink)
      found.id.should eq(@category.id)
    end

    it "return nil if not found by permalink" do
      @category.save!
      @category.permalink.should_not eq(nil)
      found = Category.find_by_permalink(@category.permalink+"_fake")
      found.should eq(nil)
    end
  end

end
