require 'app_spec_helper'
require File.join(File.dirname(__FILE__), '..', '..', 'app', 'queue_item_api_app')
include HttpStatusCodes

describe QueueItemApiApp do
  def app
    QueueItemApiApp
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe "GET /:id.json" do

    before :each do
      #pending "getting this finished"
      @qitem = FactoryGirl.create(:qitem)
      get "/#{@qitem.id}.json"
    end

    it "should return an OK code" do
      #pending "getting this finished"
      last_response.status.should eq OK
    end

    it "should return proper content type" do
      #pending "getting this finished"
      last_response.headers['Content-Type'].should eq JSON_CONTENT
    end

    it "should return valid JSON payload" do
      pending "getting this finished"
      qitem = QueueItem.new.extend  QueueItemRepresenter
      qitem.from_json(last_response.body)
      qitem.action.should eq @qitem.action
    end

    it "should return 404 if not found" do
      #pending "getting this finished"
      get "/#{@qitem.id}notfound.json"
      last_response.status.should eq NOT_FOUND
    end
  end

  describe "POST /" do
    before :each do
      #pending "getting this finished"
      #@qitem = FactoryGirl.build(:qitem).extend(QueueItemRepresenter)
      req = {
        "credential_id" => '1',
        "stack_name" => 'MockStack',
        "action" => 'the.ansibleserver.com:1 2',
      }
      post "/",  req.to_json, :account_id=>'1'
    end

    it "should return OK" do
      #pending "getting this finished"
      last_response.status.should eq CREATED
    end

    it "should return the proper content type" do
      #pending "getting this finished"
      last_response.headers["Content-Type"].should eq JSON_CONTENT
    end


    it "should return a bad request status if stack_name is missing" do
      pending "getting this finished"
      req = {
        "credential_id" => '1',
        "stack_name" => nil,
        "action" => 'the.ansibleserver.com:1 2',
      }
      post "/", req.to_json
      expected_json = "{\"error\":{\"message\":\"Data can't be blank\",\"validation_errors\":{\"data\":[\"can't be blank\"]}}}"
      last_response.body.should eq expected_json
    end
    
    it "should save the queue item properly" do
      pending "getting this finished"
      @qitem.reload
    end
  end
end
