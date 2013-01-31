require 'service_spec_helper'

describe Project do
  before :each do
    @owner = FactoryGirl.create(:account)
    @project = FactoryGirl.build(:project)
    @project.owner = @owner
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#initialize" do
    it "should initialize properly" do
      @project.should_not eq(nil)
    end

    it "project_type should default to standard" do
      @project.project_type.should eq(Project::STANDARD)
    end
  end

  describe "#valid?" do
    it "should require name" do
      @project.valid?.should eq(true)
      @project.name = nil
      @project.valid?.should eq(false)
      @project.errors[:name].length.should eq(1)
    end

    it "should require active project to save" do
      @project.status = Project::ARCHIVED
      @project.valid?.should eq(false)
      @project.errors[:status].length.should eq(1)
    end
  end

  describe "#cloud_account=" do
    it "should set the cloud_account_id using a cloud_account instance" do
      @cloud_account = FactoryGirl.build(:cloud_account)
      @account_1 = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
      @account_1.cloud_accounts << @cloud_account
      @account_1.save!
      @project.cloud_account = @cloud_account
      @project.cloud_account_id.should eq(@cloud_account.id.to_s)
      @project.cloud_account.id.to_s.should eq(@cloud_account.id.to_s)
    end

    it "should set the cloud_account_id using a string" do
      cloud_account = FactoryGirl.build(:cloud_account)
      @project.cloud_account = cloud_account.id.to_s
      @project.cloud_account_id.should eq(cloud_account.id.to_s)
    end
  end

  describe "#create_owner_membership" do
    it "should create an owner membership on create" do
      @account_1 = FactoryGirl.create(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
      @project.owner = @account_1
      @project.members.length.should eq(0)
      @project.save!
      @project.members.length.should eq(1)
      @project.members.first.last_opened_at.should_not eq(nil)
    end
  end

  describe "#archive!" do
    before :each do
      @project.save!
      @project.archive!
    end

    it "should set as archived" do
      @project.active?.should eq(false)
      @project.archived?.should eq(true)
    end

    it "should not allow saving the model if archived" do
      @project.name = "Changed"
      lambda { @project.save! }.should raise_error
    end

    it "can be reactivated" do
      @project.active!
      @project.active?.should eq(true)
      @project.archived?.should eq(false)
    end
  end

  describe "#create_current_version" do
    before :each do
      @project.save!
    end

    it "should create a current template after create" do
      @project.project_versions.count.should eq(1)
    end

    it "should not create a current template after save" do
      @project.name = "Temp"
      @project.save!
      @project.project_versions.count.should eq(1)
    end
  end

  describe "#current_version" do
    before :each do
      @project.save!
      @project.project_versions << ProjectVersion.new(:version=>"1.0.0")
      @project.project_versions << ProjectVersion.new(:version=>"1.0.1")
    end

    it "should retrieve the template" do
      @project.project_versions.count.should eq(3)
      @project.current_version.should_not eq(nil)
      @project.current_version.version.should eq(ProjectVersion::CURRENT)
    end
  end

  describe "#freeze!" do
    before :each do
      @project.save!
      @version = FactoryGirl.build(:version, :versionable=>@project)
      @project.freeze!(@version)
    end

    it "should create a new template version" do
      @project.project_versions.count.should eq(2) # current + new version
      last = @project.project_versions.last
    end

    it "should add the version to the project" do
      @project.versions.count.should eq(1) # new version, current isn't a valid version in the list
      @project.versions.first.number.should eq(@version.number)
    end

    # TODO: add examples for other embedded documents, when implemented
  end

  describe "#add_environment!" do
    before :each do
      @environment = FactoryGirl.build(:environment)
      @project.add_environment!(@environment)
    end

    it "should add the environment to the project" do
      @project.environments.count.should eq(1)
    end
  end

  describe "#remove_environment!" do
    before :each do
      @environment = FactoryGirl.build(:environment)
      @project.add_environment!(@environment)
      @project.add_environment!(FactoryGirl.build(:environment, :name=>"dev"))
    end

    it "should remove the environment to the project" do
      @project.environments.count.should eq(2)
      @project.remove_environment!(@environment.name)
      @project.environments.count.should eq(1)
      @project.environments.first.name.should eq("dev")
    end

    it "should remove variants for the environment from the current version only" do
      @variant_stage = FactoryGirl.build(:variant, :environment=>@environment.name, :variantable=>@project.current_version)
      @variant_dev = FactoryGirl.build(:variant, :environment=>'dev', :variantable=>@project.current_version)
      @variant_stage.save!
      @variant_dev.save!
      @project.reload
      @project.current_version.variants.count.should eq(2)
      @project.remove_environment!(@environment.name)
      @project.current_version.variants.count.should eq(1)
      @project.current_version.variants.first.environment.should eq('dev')
    end
  end

  describe "#delete" do
    before :each do
      @project.save!
    end

    it "should delete all project_versions" do
      ProjectVersion.count.should eq(1) # current
      @project.delete
      ProjectVersion.count.should eq(0)
    end

    it "should not delete the owner" do
      owner = @project.owner
      @project.delete
      owner.reload
    end
  end

  describe "#find_membership" do
    before :each do
      @project.save!
    end

    it "should return the member model for an account" do
      @project.find_membership(@owner.id).should_not eq(nil)
    end

    it "should return nil if not found" do
      @project.find_membership(@project.id).should eq(nil)
    end
  end

  describe "#opened_by!" do
    before :each do
      @project.save!
    end

    it "should mark the membership entry as opened when an ObjectID is provided" do
      member = @project.find_membership(@owner.id)
      member.update_attribute(:last_opened_at, nil)

      now = Time.now
      @project.opened_by!(@owner.id, now)
      member.last_opened_at.to_s.should eq(now.to_s)
    end
  end
end
