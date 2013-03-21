require 'service_spec_helper'

describe ProjectVersion do
  before :each do
    @owner = FactoryGirl.build(:account, :login=>"standard_owner_1", :email=>"standard_owner_1@example.com")
    @project = FactoryGirl.build(:project)
    @project.owner = @owner
    @project.save!
    @project_version = FactoryGirl.build(:project_version, :project=>@project)
    @project_version.save!
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#find_for_project" do
    it "should locate by project id and version" do
      pv = ProjectVersion.find_for_project(@project.id, @project_version.version)
      pv.should_not eq(nil)
      pv.id.should eq(@project_version.id)
      pv.project_id.should eq(@project.id)
      pv.version.should eq(@project_version.version)
    end

    it "should return nil if not found" do
      pv = ProjectVersion.find_for_project(@project.id, @project_version.version+"_notfound")
      pv.should eq(nil)
    end
  end
end
