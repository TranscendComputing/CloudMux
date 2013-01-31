require 'app_spec_helper'

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'cloud_api_app')

include HttpStatusCodes

describe CloudApiApp do
  def app
    CloudApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "GET /" do
    before :each do
      @cloud = FactoryGirl.create(:cloud)
      FactoryGirl.create_list(:cloud, 30)
      @total = Cloud.count
    end

    describe "defaults" do
      before :each do
        get "/"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return all results by default" do
        @cloud_query = CloudQuery.new
        @cloud_query.extend(CloudQueryRepresenter)
        @cloud_query.from_json(last_response.body)
        @cloud_query.query.should_not eq(nil)
        @cloud_query.clouds.length.should eq(@total)
        @cloud_query.query.offset.should eq(0)
        @cloud_query.query.total.should eq(@total)
        @cloud_query.query.page.should eq(1)
      end
    end
  end

  describe "GET /:id.json" do
    before :each do
      @cloud = FactoryGirl.create(:cloud)
      get "/#{@cloud.id}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid JSON payload" do
      cloud = Cloud.new.extend(CloudRepresenter)
      cloud.from_json(last_response.body)
      cloud.id.should eq(@cloud.id)
      cloud.name.should eq(@cloud.name)
      cloud.name.should eq(@cloud.name)
    end

    it "should return 404 if not found" do
      get "/#{@cloud.id}notfound.json"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "POST /" do
    before :each do
      @create_cloud = FactoryGirl.build(:cloud).extend(UpdateCloudRepresenter)
      post "/", @create_cloud.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid cloud payload" do
      new_cloud = Cloud.new.extend(CloudRepresenter)
      new_cloud.from_json(last_response.body)
      new_cloud.id.should_not eq(nil)
      new_cloud.name.should eq(@create_cloud.name)
    end

    it "should return the proper content type if data is missing" do
      @create_cloud = FactoryGirl.build(:cloud, :name=>nil).extend(UpdateCloudRepresenter)
      post "/", @create_cloud.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      @create_cloud = FactoryGirl.build(:cloud, :name=>nil).extend(UpdateCloudRepresenter)
      post "/", @create_cloud.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @create_cloud = FactoryGirl.build(:cloud, :name=>nil).extend(UpdateCloudRepresenter)
      post "/", @create_cloud.to_json
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end
  end

  describe "PUT /:id" do
    before :each do
      @cloud = FactoryGirl.create(:cloud).extend(UpdateCloudRepresenter)
      @cloud.name = "#{@cloud.name}_new"
      put "/#{@cloud.id}", @cloud.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_cloud = Cloud.new.extend(CloudRepresenter)
      updated_cloud.from_json(last_response.body)
      updated_cloud.name.should eq(@cloud.name)
      updated_cloud.name.should eq(@cloud.name)
    end
  end
  
  describe "DELETE /:id" do
    before :each do
      @cloud = FactoryGirl.create(:cloud).extend(UpdateCloudRepresenter)
      @cloud.name = "#{@cloud.name}_new"
      Cloud.find(:first, :conditions=>{ :id=>@cloud.id}).should_not eq(nil)
      delete "/#{@cloud.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should delete the cloud" do
      cloud = Cloud.find(:first, :conditions=>{ :id=>@cloud.id}).should eq(nil)
    end
  end

  describe "POST /:id/services" do
    before :each do
      @cloud = FactoryGirl.create(:cloud)
      @cloud_service = FactoryGirl.build(:cloud_service).extend(UpdateCloudServiceRepresenter)
      post "/#{@cloud.id.to_s}/services", @cloud_service.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the service properly" do
      @cloud.cloud_services.length.should eq(0)
      @cloud.reload
      @cloud.cloud_services.length.should eq(1)
    end
  end

  describe "DELETE /:id/services/:id" do
    before :each do
      @cloud = FactoryGirl.create(:cloud)
      @cloud_service = FactoryGirl.build(:cloud_service).extend(UpdateCloudServiceRepresenter)
      @cloud.cloud_services << @cloud_service
      @cloud.save!
      delete "/#{@cloud.id.to_s}/services/#{@cloud_service.id.to_s}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the service properly" do
      @cloud.cloud_services.length.should eq(1)
      @cloud.reload
      @cloud.cloud_services.length.should eq(0)
    end
  end

  describe "POST /:id/mappings" do
    before :each do
      @cloud = FactoryGirl.create(:cloud)
      @cloud_mapping = FactoryGirl.build(:cloud_mapping).extend(UpdateCloudMappingRepresenter)
      @cloud_mapping.properties = { }
      @cloud_mapping.mapping_entries = []
      post "/#{@cloud.id.to_s}/mappings", @cloud_mapping.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the mapping properly" do
      @cloud.cloud_mappings.length.should eq(0)
      @cloud.reload
      @cloud.cloud_mappings.length.should eq(1)
    end
  end

  describe "DELETE /:id/mappings/:id" do
    before :each do
      @cloud = FactoryGirl.create(:cloud)
      @cloud_mapping = FactoryGirl.build(:cloud_mapping).extend(UpdateCloudMappingRepresenter)
      @cloud.cloud_mappings << @cloud_mapping
      @cloud.save!
      delete "/#{@cloud.id.to_s}/mappings/#{@cloud_mapping.id.to_s}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the mapping properly" do
      @cloud.cloud_mappings.length.should eq(1)
      @cloud.reload
      @cloud.cloud_mappings.length.should eq(0)
    end
  end
end
