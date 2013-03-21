require 'service_spec_helper'

describe NewsEvent do
  before :each do
    @news_event = FactoryGirl.build(:news_event)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#valid" do
    it "should require a description" do
      @news_event.valid?.should eq(true)
      @news_event.description = nil
      @news_event.valid?.should eq(false)
    end
  end
  
  describe "#valid" do
    it "should require a posted date" do
      @news_event.valid?.should eq(true)
      @news_event.posted = nil
      @news_event.valid?.should eq(false)
    end
  end
  
  describe "#valid" do
    it "should require a url" do
      @news_event.valid?.should eq(true)
      @news_event.url = nil
      @news_event.valid?.should eq(false)
    end
  end

end
