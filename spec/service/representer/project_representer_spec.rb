require 'service_spec_helper'

describe ProjectRepresenter do

  before :each do
    @project = FactoryGirl.build(:project)

    @cloud_account = FactoryGirl.build(:cloud_account)
    @account_1 = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
    @account_1.cloud_accounts << @cloud_account
    @account_1.save!

    @account_1.reload
    @project.cloud_account = @cloud_account
    @project.owner = @account_1
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#to_json" do
    it "should export to json" do
      @project.extend(ProjectRepresenter)
      result = @project.to_json
      result.should eq("{\"project\":{\"id\":\"#{@project.id}\",\"status\":\"#{@project.status}\",\"name\":\"#{@project.name}\",\"description\":\"#{@project.description}\",\"project_type\":\"#{@project.project_type}\",\"region\":\"#{@project.region}\",\"owner\":{\"id\":\"#{@account_1.id}\",\"login\":\"#{@account_1.login}\"},\"cloud_account\":{\"cloud_account\":{\"id\":\"#{@cloud_account.id}\",\"name\":\"#{@cloud_account.name}\",\"audit_logs\":[]}},\"members\":[],\"versions\":[],\"environments\":[],\"provisioned_versions\":[]}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"project\":{\"id\":\"#{@project.id}\",\"name\":\"#{@project.name}\",\"description\":\"#{@project.description}\",\"owner\":{\"id\":\"#{@account_1.id}\",\"login\":\"#{@account_1.login}\"},\"cloud_account\":{\"cloud_account\":{\"id\":\"#{@cloud_account.id}\",\"name\":\"#{@cloud_account.name}\",\"audit_logs\":[]}}}}"
      new_project = Project.new
      new_project.extend(ProjectRepresenter)
      new_project.from_json(json)
      new_project.name.should eq(@project.name)
      new_project.description.should eq(@project.description)
      new_project.id.should eq(@project.id)
    end
  end
end
