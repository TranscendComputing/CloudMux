require 'app_spec_helper'

include HttpStatusCodes

describe QueueItemApiApp do
  def app
    QueueItemApiApp
  end

  #before :each do 
  #  @a1 = FactoryGirl.build(:account, :login=>'standard_subscriber_1', :email=>'standard_1@example.com')
  #  @a1.save
  #end

  after :each do
    DatabaseCleaner.clean
  end

  describe "GET /:id.json" do

    before :each do
      pending "getting this finished"
      @qitem = FactoryGirl.create(:qitem)
    end

    describe "defaults" do
      before :each do
        get "/#{@qitem.id}.json"
      end

      it "should return an OK code" do
        pending "getting this finished"
        last_response.status.should eq OK
      end

      it "should return proper content type" do
        pending "getting this finished"
        last_response.headers['Content-Type'].should eq JSON_CONTENT
      end

      it "should return valid JSON payload" do
        pending "getting this finished"
        qitem = QueueItem.new
        qitem.extend QueueItemRepresenter
        qitem.from_json last_response.body
        qitem.id.should eq @qitem.id
      end

      it "should return 404 if not found" do
        pending "getting this finished"
        get "/#{@qitem.id}notfound.json"
        last_response.status.should eq NOT_FOUND
      end
    end
  end

  describe "POST /" do
    before :each do
      pending "getting this finished"
      @qitem = FactoryGirl.build(:qitem).extend QueueItemRepresenter
      post "/", @qitem.to_json
    end

    it "should return OK" do
      pending "getting this finished"
      last_response.status.should eq CREATED
    end

    it "should return the proper content type" do
      pending "getting this finished"
      last_response.headers["Content-Type"].should eq JSON_CONTENT
    end

    it "should return a valid QueueItem paylod" do
      pending "getting this finished"
      qitem = QueueItem.new.extend(QueueItem)
      qitem.from_json last_response.body
      print qitem
      qitem.id.should_not eq nil
      qitem.name should eq @qitem.name
    end

    it "should return a bad request status if data is missing" do
      pending "getting this finished"
      @qitem = FactoryGirl.build(:qitem, :data => nil).extend(QueueItemRepresenter)
      post "/", @qitem.to_json
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq expected_json
    end
    
    it "should save the queue item properly" do
      pending "getting this finished"
      @qitem.reload
    end
  end
end
