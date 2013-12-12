require 'app_spec_helper'
require 'ruby-debug'

require  File.join(APP_DIR, 'queue_item_api_app')

include HttpStatusCodes

describe QueueItemApiApp do
  def app
    QueueItemApiApp
  end

  before :each do 
    @cc = FactoryGirl.build(:cloud_credential)
    @a1 = FactoryGirl.build(:account, :login=>'standard_subscriber_1', :email=>'standard_1@example.com')
    @a1.save
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe "GET /:id.json" do
    before :each do
      @qitem = FactoryGirl.create(:qitem)
      get "/#{@qitem.id}.json"
    end

    it "should return an OK code" do
      last_response.status.should eq OK
    end

    it "should return proper content type" do
      last_response.headers['Content-Type'].should eq JSON_CONTENT
    end

    it "should return valid JSON payload" do
      qitem = QueueItem.new.extend QueueItemRepresenter
      qitem.from_json last_response.body
      qitem.id.should eq @qitem.id
    end

    it "should return 404 if not found" do
      get "/#{@qitem.id}notfound.json"
      last_response.status.should eq NOT_FOUND
    end
  end

  describe "POST /" do
    before :each do
      @qitem = FactoryGirl.build(:qitem).extend QueueItemRepresenter
      post "/", @qitem.to_json
    end

    it "should return OK" do
      last_response.status.should eq CREATED
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq JSON_CONTENT
    end

    it "should return a valid QueueItem paylod" do
      qitem = QueueItem.new.extend(QueueItem)
      qitem.from_json last_response.body
      qitem.id.should_not eq nil
      qitem.name should eq @qitem.name
    end

    it "should return a bad request status if data is missing" do
      @qitem = FactoryGirl.build(:qitem, :data => nil).extend(QueueItemRepresenter)
      post "/", @qitem.to_json
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq expected_json
    end
  end
end
