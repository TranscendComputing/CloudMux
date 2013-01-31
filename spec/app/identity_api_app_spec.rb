require 'app_spec_helper'
include HttpStatusCodes

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'identity_api_app')

describe "IdentityApiApp" do
  def app
    IdentityApiApp
  end

  before :each do
    Account.any_instance.stub(:bcrypt_cost).and_return(1)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "POST /" do
    before :each do
      @country = FactoryGirl.create(:country)
      @new_account = FactoryGirl.build(:account, :country=>@country)
      @response = create_account_request(@new_account)
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return the proper content type if data is missing" do
      @new_account = FactoryGirl.build(:account, :login=>nil)
      response = create_account_request(@new_account)
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      @new_account = FactoryGirl.build(:account, :login=>nil)
      response = create_account_request(@new_account)
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @new_account = FactoryGirl.build(:account, :login=>nil, :email=>"unique@test.local")
      response = create_account_request(@new_account)
      expected_json = "{\"error\":{\"message\":\"Login can't be blank\",\"validation_errors\":{\"login\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end

    it "should return a valid account payload" do
      @account = Account.new
      @account.extend(AccountRepresenter)
      @account.from_json(@response)
      @account.login.should eq(@new_account.login)
      @account.id.should_not eq(nil)
    end
  end

  describe "POST /auth" do
    before :each do
      @account = FactoryGirl.build(:account)
      @account.password = 'test12345'
      @account.save!
      @response = auth_request(@account.login, @account.password)
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return the proper content type if data is missing" do
      auth_request(@account.login, "wrong-password")
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      auth_request(@account.login, "wrong-password")
      last_response.status.should eq(NOT_AUTHORIZED)
    end

    it "should return a message if data is missing" do
      auth_request(@account.login, "wrong-password")
      expected_json = "{\"error\":{\"message\":\"Invalid login or password\"}}"
     last_response.body.should eq(expected_json)
    end

    it "should return a bad request if required parameters are missing" do
      post "/auth"
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if required parameters are missing" do
      post "/auth"
      expected_json = "{\"error\":{\"message\":\"Login and password are required\"}}"
      last_response.body.should eq(expected_json)
    end

    it "should return a valid account payload" do
      account_details = Account.new.extend(AccountRepresenter)
      account_details.from_json(@response)
      account_details.login.should eq(@account.login)
    end
  end

  describe "GET /:id.json" do
    before :each do
      @account = FactoryGirl.build(:account)
      @account.save!
      get "/#{@account.id}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return 404 if not found" do
      get "/#{@account.id}notfound.json"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "PUT /:id" do
    before :each do
      @account = FactoryGirl.build(:account).extend(UpdateAccountRepresenter)
      @account.save!
      @old_password = @account.encrypted_password
      @account.password = nil
      @expected_email = "new@test.com"
      @account.email = @expected_email
      put "/#{@account.id}", @account.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_account = Account.new.extend(AccountRepresenter)
      updated_account.from_json(last_response.body)
      updated_account.login.should eq(@account.login)
      updated_account.email.should eq(@expected_email)
    end

    it "should not reset the password if a new password is not given" do
      # check against the stored value in the DB
      @account.reload
      @account.encrypted_password.should eq(@old_password)
    end
  end

  describe "GET /countries.json" do
    before :each do
      @countries = FactoryGirl.create_list(:country, 25)
      get "/countries.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload" do
      query = CountryQuery.new.extend(CountryQueryRepresenter)
      query.from_json(last_response.body)
      query.countries.length.should eq(@countries.length)
    end
  end

  describe "POST /:id/:cloud_id/cloud_accounts" do
    before :each do
      @account = FactoryGirl.create(:account)
      @cloud = FactoryGirl.create(:cloud)
      @cloud_account = FactoryGirl.build(:cloud_account).extend(UpdateCloudAccountRepresenter)
      post "/#{@account.id}/#{@cloud.id}/cloud_accounts", @cloud_account.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the change" do
      @account.reload
      @account.cloud_accounts.length.should eq(1)
    end

    it "should return a valid payload with updated fields" do
      updated_account = Account.new.extend(AccountRepresenter)
      updated_account.from_json(last_response.body)
      updated_account.cloud_accounts.length.should eq(1)
    end
  end

  describe "DELETE /:id/cloud_accounts/:cloud_account_id" do
    before :each do
      @account = FactoryGirl.create(:account)
      @cloud = FactoryGirl.create(:cloud)
      @cloud_account = FactoryGirl.build(:cloud_account).extend(UpdateCloudAccountRepresenter)
      @account.cloud_accounts << @cloud_account
      @account.save!
      delete "/#{@account.id}/cloud_accounts/#{@cloud_account.id}"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should save the change" do
      @account.reload
      @account.cloud_accounts.length.should eq(0)
    end

    it "should return a valid payload with updated fields" do
      updated_account = Account.new.extend(AccountRepresenter)
      updated_account.from_json(last_response.body)
      updated_account.cloud_accounts.length.should eq(0)
    end
  end

  describe "GET /cloud_accounts/:id/" do
    before :each do
      @account = FactoryGirl.create(:account)
      @cloud_account = FactoryGirl.build(:cloud_account)
      @account.cloud_accounts << @cloud_account
      @account.save!
      get "/cloud_accounts/#{@cloud_account.id}.json"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      cloud_account = CloudAccount.new.extend(CloudAccountRepresenter)
      cloud_account.from_json(last_response.body)
    end
  end

end

def create_account_request(new_account)
  new_account.extend(UpdateAccountRepresenter)
  post "/", new_account.to_json
  last_response.body
end

def auth_request(login, password)
  post "/auth", { :login=>login, :password=>password}
  last_response.body
end
