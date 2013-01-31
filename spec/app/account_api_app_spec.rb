require 'app_spec_helper'
include HttpStatusCodes

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'account_api_app')

# POST /users - create an account
# POST /users/auth - return (TBD) HTTP status code to indicate the auth failed, or return (TBD) HTTP status code + JSON payload with account info if it succeeded
# GET /users/:user_id - return a user's account details, for things like obtaining the most current email address before sending an email
# PUT /users/:user_id - update a user's account details, including login, email, etc.

describe "AccountApiApp" do
  def app
    AccountApiApp
  end

  before :each do
    Account.any_instance.stub(:bcrypt_cost).and_return(1)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
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
end
