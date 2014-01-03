# require 'app_spec_helper'

# require File.join(APP_DIR, 'orchestration', 'config_manager_validator_api_app')
# require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'cloudmux', 'configuration_manager.rb')

# include HttpStatusCodes

# describe ConfigManagerValidatorApiApp do

#   after :each do
#     # this test uses the db storage for uniqueness testing, so need to clean between runs
#     DatabaseCleaner.clean
#   end

#   describe "GET /" do
#     # before :each do
#     #   # @config_manager = FactoryGirl.create(:configuration_manager)
#     #   config_manager = ConfigManager.all.first
#     #   @manager_client = CloudMux::ConfigurationManager.new(config_manager)
#     # end

#     describe "defaults" do
#       before :each do
#         get "/"
#       end

#       it "should return a success response code" do
#         last_response.status.should eq(OK)
#       end
#     end
#   end

#   # describe "POST /" do
#   #   before :each do
#   #     @create_cloud = FactoryGirl.build(:cloud).extend(UpdateCloudRepresenter)
#   #     post "/", @create_cloud.to_json
#   #   end

#   #   it "should return a success response code" do
#   #     last_response.status.should eq(CREATED)
#   #   end

#   #   it "should return the proper content type" do
#   #     last_response.headers["Content-Type"].should eq(JSON_CONTENT)
#   #   end

#   #   it "should return a valid cloud payload" do
#   #     new_cloud = Cloud.new.extend(CloudRepresenter)
#   #     new_cloud.from_json(last_response.body)
#   #     new_cloud.id.should_not eq(nil)
#   #     new_cloud.name.should eq(@create_cloud.name)
#   #   end

#   #   it "should return the proper content type if data is missing" do
#   #     @create_cloud = FactoryGirl.build(:cloud, :name=>nil).extend(UpdateCloudRepresenter)
#   #     post "/", @create_cloud.to_json
#   #     last_response.headers["Content-Type"].should eq(JSON_CONTENT)
#   #   end

#   #   it "should return a bad request status if data is missing" do
#   #     @create_cloud = FactoryGirl.build(:cloud, :name=>nil).extend(UpdateCloudRepresenter)
#   #     post "/", @create_cloud.to_json
#   #     last_response.status.should eq(BAD_REQUEST)
#   #   end

#   #   it "should return a message if data is missing" do
#   #     @create_cloud = FactoryGirl.build(:cloud, :name=>nil).extend(UpdateCloudRepresenter)
#   #     post "/", @create_cloud.to_json
#   #     expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
#   #     last_response.body.should eq(expected_json)
#   #   end
#   # end
  
# end
