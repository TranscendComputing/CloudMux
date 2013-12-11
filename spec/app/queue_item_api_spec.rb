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

  describe "GET /:id" do
    before :each do
      @qitem = FactoryGirl.create(:qitem)
    end

    it "should return an OK code" do
      last_response.status.should eq OK
    end

    it "should return as JSON" do
      last_response.headers['Content-Type'].should eq JSON_CONTENT
    end

    it "should return valid QueueItem data" do
      qitem = QueueItem.new.extend QueueItemRepresenter
      qitem.from_json last_response.body
      qitem.id.should eq @qitem.id
    end
  end
end
