require 'service_spec_helper'

describe Version do

  before :each do
    @version = FactoryGirl.build(:version)
  end

  describe "#validate_format" do
    it "should allow for current as a valid version" do
      @version.number = 'current'
      @version.valid?.should eq(true)
    end

    it "should allow for correct format" do
      @version.number = '1.0.0'
      @version.valid?.should eq(true)
      @version.number = '0.1.0'
      @version.valid?.should eq(true)
      @version.number = '100.200.400'
      @version.valid?.should eq(true)
    end

    it "should fail if not the correct format" do
      @version.number = '1.0'
      @version.valid?.should eq(false)
      @version.number = '0.1'
      @version.valid?.should eq(false)
      @version.number = 'not_even_close'
      @version.valid?.should eq(false)
    end
  end

  describe "#validate_version_number" do
    it "should return true if there are no other versions" do
      @version.validate_version_number([]).should eq(true)
      @version.validate_version_number(nil).should eq(true)
    end

    it "should return true if current is greater than the last" do
      lower = FactoryGirl.build(:version, :number=>"0.1.0")
      @version.validate_version_number([lower]).should eq(true)
      lower = FactoryGirl.build(:version, :number=>"0.0.99")
      @version.validate_version_number([lower]).should eq(true)
      lower = FactoryGirl.build(:version, :number=>"0.99.0")
      @version.validate_version_number([lower]).should eq(true)
    end

    it "should return false if current is less than the last" do
      lower = FactoryGirl.build(:version, :number=>"1.0.1")
      @version.validate_version_number([lower]).should eq(false)
    end
  end
end
