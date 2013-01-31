require 'app_spec_helper'

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'news_event_api_app')

include HttpStatusCodes

describe NewsEventApiApp do
  def app
    NewsEventApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "GET /" do
    before :each do
      @news_event = FactoryGirl.create(:news_event)
      FactoryGirl.create_list(:news_event, 30)
      @total = NewsEvent.count
    end

    describe "defaults" do
      before :each do
        get "/"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return all results by default" do
        @news_event_query = NewsEventQuery.new
        @news_event_query.extend(NewsEventQueryRepresenter)
        @news_event_query.from_json(last_response.body)
        @news_event_query.query.should_not eq(nil)
        @news_event_query.news_events.length.should eq(@total)
        @news_event_query.query.offset.should eq(0)
        @news_event_query.query.total.should eq(@total)
        @news_event_query.query.page.should eq(1)
      end
    end
  end

  describe "POST /" do
    before :each do
      @create_news_event = FactoryGirl.build(:news_event).extend(UpdateNewsEventRepresenter)
      post "/", @create_news_event.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid news event payload" do
      new_news_event = NewsEvent.new.extend(NewsEventRepresenter)
      new_news_event.from_json(last_response.body)
      new_news_event.id.should_not eq(nil)
      new_news_event.description.should eq(@create_news_event.description)
      new_news_event.url.should eq(@create_news_event.url)
      new_news_event.source.should eq(@create_news_event.source)
      new_news_event.posted.should eq(@create_news_event.posted)
    end

    it "should return the proper content type if data is missing" do
      @create_news_event = FactoryGirl.build(:news_event, :description=>nil, :url=>nil, :posted=>nil).extend(UpdateNewsEventRepresenter)
      post "/", @create_news_event.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end   

    it "should return a bad request status if data is missing" do
      @create_news_event = FactoryGirl.build(:news_event, :description=>nil, :url=>nil, :posted=>nil).extend(UpdateNewsEventRepresenter)
      post "/", @create_news_event.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @create_news_event = FactoryGirl.build(:news_event, :description=>nil, :url=>nil, :posted=>nil).extend(UpdateNewsEventRepresenter)
      post "/", @create_news_event.to_json
      expected_json = "{\"error\":{\"message\":\"Description can't be blank;Url can't be blank;Posted can't be blank\",\"validation_errors\":{\"description\":[\"can't be blank\"],\"url\":[\"can't be blank\"],\"posted\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end
  end

  describe "PUT /:id" do
    before :each do
      @news_event = FactoryGirl.create(:news_event).extend(UpdateNewsEventRepresenter)
      @news_event.description = "#{@news_event.description}_new"
      @news_event.url = "#{@news_event.url}_new"
      @news_event.source = "#{@news_event.source}_new"
      @news_event.posted = Time.now
      put "/#{@news_event.id}", @news_event.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_news_event = NewsEvent.new.extend(NewsEventRepresenter)
      updated_news_event.from_json(last_response.body)
      updated_news_event.description.should eq(@news_event.description)
      updated_news_event.url.should eq(@news_event.url)
      updated_news_event.source.should eq(@news_event.source)
      updated_news_event.posted.should eq(@news_event.posted)
    end
  end
    
  describe "DELETE /:id" do
    before :each do
      @news_event = FactoryGirl.create(:news_event).extend(UpdateNewsEventRepresenter)
      @news_event.description = "#{@news_event.description}_new"
      NewsEvent.find(:first, :conditions=>{ :id=>@news_event.id}).should_not eq(nil)
      delete "/#{@news_event.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should delete the news_event" do
      news_event = NewsEvent.find(:first, :conditions=>{ :id=>@news_event.id}).should eq(nil)
    end
  end
end
