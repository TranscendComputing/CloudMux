require 'app_spec_helper'

include HttpStatusCodes

require File.join(APP_DIR, 'orchestration', 'config_managers_api_app')

describe ConfigManagerApiApp do
  def app
    ConfigManagerApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing,
    #  so need to clean between runs
    DatabaseCleaner.clean
  end

  describe 'GET /:id' do
    before :each do
      @config_manager = FactoryGirl.build(:config_manager)
      @config_manager.save!
      get "/#{@config_manager.id}"
    end

    it 'should return a success response code' do
      last_response.should be_ok
    end

    it 'should return the proper content type' do
      last_response.headers['Content-Type'].should eq(JSON_CONTENT)
    end

    it 'should return 404 if not found' do
      get "/#{@config_manager.id}notfound"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe 'GET /org/:org_id' do
    before :each do
      @org = FactoryGirl.build(:org)
      @org.save!
      config_manager = FactoryGirl.build(:config_manager)
      config_manager.org_id = @org.id
      config_manager.save!
      get "/org/#{@org.id}"
    end

    it 'should return a success response code' do
      last_response.should be_ok
    end

    it 'should return the proper content type' do
      last_response.headers['Content-Type'].should eq(JSON_CONTENT)
    end

    it 'should return empty array if not found' do
      get "/org/#{@org.id}notfound"
      last_response.body.should eq('[]')
    end
  end

  describe 'POST /' do
    before :each do
      req = {
        'name' => 'MockConfigManager',
        'url' => 'http://configurl.localhost',
        'branch' => 'test'
      }
      post '/', req.to_json
    end

    it 'should return a success response code' do
      last_response.status.should eq CREATED
    end

    it 'should return the proper content type' do
      last_response.headers['Content-Type'].should eq(JSON_CONTENT)
    end

    it 'should return a bad request status if name is missing' do
      req = {
        'name' => nil,
        'url' => 'http://configurl.localhost',
        'branch' => 'test'
      }
      post '/', req.to_json
      last_response.status.should eq BAD_REQUEST
    end

    it 'should return a bad request status if url is missing' do
      req = {
        'name' => 'MockConfigManager',
        'url' => nil,
        'branch' => 'test'
      }
      post '/', req.to_json
      last_response.status.should eq BAD_REQUEST
    end    
  end
end
