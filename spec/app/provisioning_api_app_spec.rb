require 'app_spec_helper'

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'provisioning_api_app')

include HttpStatusCodes

describe ProvisioningApiApp do
  def app
    ProvisioningApiApp
  end

  before :each do
    @project = create_project
    @provisioned_version = FactoryGirl.create(:provisioned_version, :project=>@project)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "POST /" do
    before :each do
      @pv = FactoryGirl.build(:provisioned_version).extend(UpdateProvisionedVersionRepresenter)
      post "/#{@project.id}", @pv.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return a valid payload" do
      pv = ProvisionedVersion.new.extend(ProvisionedVersionRepresenter)
      pv.from_json(last_response.body)
      pv.stack_name.should eq(@provisioned_version.stack_name)
      ProvisionedVersion.find(pv.id).project_id.to_s.should eq(@project.id.to_s)
    end
  end

  describe "GET /:id.json" do
    before :each do
      get "/#{@provisioned_version.id}.json"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return a valid payload" do
      pv = ProvisionedVersion.new.extend(ProvisionedVersionRepresenter)
      pv.from_json(last_response.body)
      pv.id.should eq(@provisioned_version.id)
      pv.stack_name.should eq(@provisioned_version.stack_name)
      pv.provisioned_instances.length.should eq(0)
    end
  end

  describe "POST /:provisioned_version_id/instances" do
    before :each do
      @pi = FactoryGirl.build(:provisioned_instance)
      list = Struct.new(:instances).new.extend(ProvisionedInstancesRepresenter)
      list.instances = [@pi]
      post "/#{@provisioned_version.id}/instances", list.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return a valid payload" do
      pv = ProvisionedVersion.new.extend(ProvisionedVersionRepresenter)
      pv.from_json(last_response.body)
      pv.stack_name.should eq(@provisioned_version.stack_name)
      pv.provisioned_instances.length.should eq(1)
    end
  end

  describe "DELETE /:provisioned_instance_id/instances/:instance_id" do
    before :each do
      @pi = FactoryGirl.create(:provisioned_instance, :provisioned_version=>@provisioned_version)
      delete "/#{@provisioned_version.id}/instances/#{@pi.instance_id}"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end

    it "should return a valid payload" do
      pv = ProvisionedVersion.new.extend(ProvisionedVersionRepresenter)
      pv.from_json(last_response.body)
      pv.stack_name.should eq(@provisioned_version.stack_name)
      pv.provisioned_instances.length.should eq(0)
    end
  end

  describe "DELETE /:id" do
    before :each do
      delete "/#{@provisioned_version.id}"
    end

    it "should return a success response code" do
      last_response.status.should eq(OK)
    end
  end

end
