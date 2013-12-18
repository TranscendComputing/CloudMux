require 'app_spec_helper'

require  File.join(APP_DIR, 'google', 'google_object_storage_app')

include HttpStatusCodes

describe GoogleObjectStorageApp do
  def app
    GoogleObjectStorageApp
  end

  let(:creds) do
    creds = FactoryGirl.create(:full_google_credential)
    creds.account.add_cloud_credential!(creds.cloud_account.id, creds)
    creds
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe "GET /directories" do

    before :each do
      params = {cred_id: creds.id}

      get "/directories", params
    end

    it "should return an OK code" do
      last_response.status.should eq OK
    end
  end

  describe "DELETE /directories" do

    before :each do
      params = {cred_id: creds.id}

      delete "/directories/junk", params
    end

    it "should return 404 on delete of nonexistent" do
      last_response.status.should eq NOT_FOUND
    end
  end

  describe "GET /directories/:id/files" do

    before :each do
      params = {cred_id: creds.id}

      get "/directories/junk/files", params
    end

    it "should return 404 on get of nonexistent dir" do
      last_response.status.should eq NOT_FOUND
    end
  end
end
