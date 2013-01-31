require 'app_spec_helper'
include HttpStatusCodes

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'org_api_app')

describe "OrgApiApp" do
  def app
    OrgApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "POST /" do
    before :each do
      @admin = FactoryGirl.create(:account)
      @new_org = FactoryGirl.build(:org)
      @new_org.extend(UpdateOrgRepresenter)
    end

    it "should return a success response code" do
      post "/", @new_org.to_json
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      post "/", @new_org.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid org payload" do
      post "/", @new_org.to_json
      @org = Org.new
      @org.extend(OrgRepresenter)
      @org.from_json(last_response.body)
      @org.id.should_not eq(nil)
      @org.name.should eq(@new_org.name)
    end

    it "should return the proper content type if data is missing" do
      @new_org = FactoryGirl.build(:org, :name=>nil).extend(UpdateOrgRepresenter)
      post "/", @new_org.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      @new_org = FactoryGirl.build(:org, :name=>nil).extend(UpdateOrgRepresenter)
      post "/", @new_org.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @new_org = FactoryGirl.build(:org, :name=>nil).extend(UpdateOrgRepresenter)
      post "/", @new_org.to_json
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end
  end

  describe "PUT /:id" do
    before :each do
      @admin = FactoryGirl.create(:account)
      @org = FactoryGirl.create(:org)
      @expected_name = @org.name+" new"
      @org.extend(UpdateOrgRepresenter)
      @org.name = @expected_name
      put "/#{@org.id}", @org.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_org = Org.new.extend(OrgRepresenter)
      updated_org.from_json(last_response.body)
      updated_org.id.to_s.should eq(@org.id.to_s)
      updated_org.name.should eq(@expected_name)
    end
  end

  describe "PUT /:id/:product/subscription" do
    before :each do
      @admin = FactoryGirl.create(:account)
      @org = FactoryGirl.create(:org)
      @subscription = FactoryGirl.build(:subscription, :billing_level=>"my_level").extend(UpdateSubscriptionRepresenter)
    end

    it "should return a success response code" do
      put "/#{@org.id}/#{@subscription.product}/subscription", @subscription.to_json
      last_response.should be_ok
    end

    it "should return the proper content type" do
      put "/#{@org.id}/#{@subscription.product}/subscription", @subscription.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with subscription fields" do
      put "/#{@org.id}/#{@subscription.product}/subscription", @subscription.to_json
      updated_org = Org.new.extend(OrgRepresenter)
      updated_org.from_json(last_response.body)
      updated_org.id.to_s.should eq(@org.id.to_s)
      updated_org.subscriptions.length.should eq(1)
      updated_org.subscriptions.first.product.should eq(@subscription.product)
      updated_org.subscriptions.first.billing_level.should eq(@subscription.billing_level)
    end

    it "should update an existing subscription if found for a product" do
      @org.subscriptions << @subscription
      @org.save!
      @org.subscriptions.length.should eq(1)
      @subscription_2 = FactoryGirl.build(:subscription, :billing_level=>"test_level").extend(UpdateSubscriptionRepresenter)
      put "/#{@org.id}/#{@subscription_2.product}/subscription", @subscription_2.to_json
      updated_org = Org.new.extend(OrgRepresenter)
      updated_org.from_json(last_response.body)
      updated_org.id.to_s.should eq(@org.id.to_s)
      updated_org.subscriptions.length.should eq(1)
      updated_org.subscriptions.first.product.should eq(@subscription_2.product)
      updated_org.subscriptions.first.billing_level.should eq(@subscription_2.billing_level)
    end
  end

  describe "POST /:id/:product/subscribers" do
    before :each do
      @admin = FactoryGirl.create(:account)
      @org = FactoryGirl.build(:org)
      @subscription = FactoryGirl.build(:subscription)
      @org.subscriptions << @subscription
      @org.save!
      @subscriber = Struct.new(:account_id, :role).new(@admin.id.to_s, 'admin').extend(AddSubscriberRepresenter)
    end

    it "should return a success response code" do
      post "/#{@org.id}/#{@subscription.product}/subscribers", @subscriber.to_json
      last_response.should be_ok
    end

    it "should return the proper content type" do
      post "/#{@org.id}/#{@subscription.product}/subscribers", @subscriber.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      @org.subscriptions.first.subscribers.length.should eq(0)
      post "/#{@org.id}/#{@subscription.product}/subscribers", @subscriber.to_json
      @org.reload
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(1)
      @org.subscriptions.first.subscribers.first.account.id.to_s.should eq(@subscriber.account_id.to_s)
      @org.subscriptions.first.subscribers.first.role.should eq(@subscriber.role)
    end

    it "should succeed but only create one entry" do
      post "/#{@org.id}/#{@subscription.product}/subscribers", @subscriber.to_json
      last_response.should be_ok
      post "/#{@org.id}/#{@subscription.product}/subscribers", @subscriber.to_json
      last_response.should be_ok
      @org.reload
      @org.subscriptions.first.subscribers.length.should eq(1)
    end

    it "should return a 400 status if the product isn't found" do
      post "/#{@org.id}/#{@subscription.product}_fake/subscribers", @subscriber.to_json
      last_response.status.should eq(BAD_REQUEST)
    end
  end

  describe "DELETE /:id/:product/subscribers/:subscriber_account_id" do
    before :each do
      @admin = FactoryGirl.create(:account)
      @org = FactoryGirl.build(:org)
      @subscription = FactoryGirl.build(:subscription)
      @subscriber = FactoryGirl.build(:subscriber, :account_id=>@admin.id.to_s, :role=>'admin').extend(SubscriberRepresenter)
      @subscription.subscribers << @subscriber
      @org.subscriptions << @subscription
      @org.save!
    end

    it "should return a success response code" do
      delete "/#{@org.id}/#{@subscription.product}/subscribers/#{@subscriber.account_id.to_s}"
      last_response.should be_ok
    end

    it "should return the proper content type" do
      delete "/#{@org.id}/#{@subscription.product}/subscribers/#{@subscriber.account_id.to_s}"
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a 400 status if the product isn't found" do
      delete "/#{@org.id}/#{@subscription.product}_fake/subscribers/#{@subscriber.account_id.to_s}"
      last_response.status.should eq(BAD_REQUEST)
    end
  end

  describe "GET /:id.json" do
    before :each do
      @admin = FactoryGirl.create(:account)
      @org = FactoryGirl.build(:org)
      @subscription = FactoryGirl.build(:subscription)
      @subscriber = FactoryGirl.build(:subscriber, :account_id=>@admin.id.to_s, :role=>'admin').extend(SubscriberRepresenter)
      @subscription.subscribers << @subscriber
      @org.subscriptions << @subscription
      @org.save!
      get "/#{@org.id.to_s}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload" do
      org = Org.new.extend(OrgRepresenter)
      org.from_json(last_response.body)
      org.subscriptions.length.should eq(1)
      org.subscriptions.first.subscribers.length.should eq(1)
      org.subscriptions.first.subscribers.first.account_id.to_s.should eq(@subscriber.account_id.to_s)
      org.subscriptions.first.subscribers.first.role.should eq(@subscriber.role)
    end

    it "should return a 404 status if the product isn't found" do
      get "/#{@org.id}_not_found"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "POST /:id/mappings" do
    before :each do
      @org = FactoryGirl.create(:org)
      @cloud_mapping = FactoryGirl.build(:cloud_mapping).extend(UpdateCloudMappingRepresenter)
      @cloud_mapping.properties = { }
      @cloud_mapping.mapping_entries = []
      post "/#{@org.id.to_s}/mappings", @cloud_mapping.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the mapping properly" do
      @org.cloud_mappings.length.should eq(0)
      @org.reload
      @org.cloud_mappings.length.should eq(1)
    end
  end

  describe "DELETE /:id/mappings/:id" do
    before :each do
      @org = FactoryGirl.create(:org)
      @cloud_mapping = FactoryGirl.build(:cloud_mapping).extend(UpdateCloudMappingRepresenter)
      @org.cloud_mappings << @cloud_mapping
      @org.save!
      delete "/#{@org.id.to_s}/mappings/#{@cloud_mapping.id.to_s}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the mapping properly" do
      @org.cloud_mappings.length.should eq(1)
      @org.reload
      @org.cloud_mappings.length.should eq(0)
    end
  end
end
