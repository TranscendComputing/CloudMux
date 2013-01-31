require 'service_spec_helper'

describe Template do
  before :each do
    @template = FactoryGirl.build(:template)
  end

  describe "#initialize" do
    it "should initialize properly" do
      @template.should_not eq(nil)
    end
  end

  describe "#valid?" do
    it "should require name" do
      @template.valid?.should eq(true)
      @template.name = nil
      @template.valid?.should eq(false)
    end

    it "should require template_type" do
      @template.valid?.should eq(true)
      @template.template_type = nil
      @template.valid?.should eq(false)
    end

    it "should require raw_json" do
      @template.valid?.should eq(true)
      @template.raw_json = nil
      @template.valid?.should eq(false)
    end

    it "should require valid json" do
      @template.valid?.should eq(true)
      @template.raw_json = "invalid"
      @template.valid?.should eq(false)
    end
  end
end
