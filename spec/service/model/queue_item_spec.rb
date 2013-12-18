require 'service_spec_helper'

describe QueueItem do
  before :each do
    @qitem = FactoryGirl.build :qitem  
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe "#initialize" do
    it "should initialize properly" do
      pending "Still needs to be implemented"
      @qitem.create.should_not eq nil
    end
  end
  
  describe "#valid?" do
    #it should be a valid model of queue item
    it "should require a create time" do
      pending "Still needs to be implemented"
      @qitem.valid?.should eq true
      @qitem.create = nil
      @qitem.valid?.should eq false
      @qitem.errors[:create].length.should eq 1
    end
  end
end
