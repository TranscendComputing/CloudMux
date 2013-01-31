require 'service_spec_helper'

describe NewsEventRepresenter do

  before :each do
    @news_event = FactoryGirl.build(:news_event)
  end

  describe "#to_json" do
    it "should export to json" do
      @news_event.extend(NewsEventRepresenter)
      result = @news_event.to_json
      result.should eq("{\"news_event\":{\"id\":\"#{@news_event.id}\",\"description\":\"#{@news_event.description}\",\"url\":\"#{@news_event.url}\",\"source\":\"#{@news_event.source}\",\"posted\":\"#{@news_event.posted}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"news_event\":{\"id\":\"#{@news_event.id}\",\"description\":\"#{@news_event.description}\",\"url\":\"#{@news_event.url}\",\"source\":\"#{@news_event.source}\",\"posted\":\"#{@news_event.posted}\"}}"
      new_news_event = NewsEvent.new
      new_news_event.extend(NewsEventRepresenter)
      new_news_event.from_json(json)
      new_news_event.description.should eq(@news_event.description)
      new_news_event.url.should eq(@news_event.url)
      new_news_event.source.should eq(@news_event.source)
      new_news_event.posted.should eq(@news_event.posted)
      new_news_event.id.should eq(@news_event.id)
    end
  end
end
