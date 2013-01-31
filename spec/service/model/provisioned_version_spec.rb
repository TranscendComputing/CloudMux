require 'service_spec_helper'

describe ProvisionedVersion do

  before :each do
    @pv = FactoryGirl.build(:provisioned_version)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#find_instance" do
    it "should locate an instance by instance_id" do
      pi = FactoryGirl.create(:provisioned_instance, :provisioned_version=>@pv)
      found = @pv.find_instance(pi.instance_id)
      found.should_not eq(nil)
      found.instance_id.should eq(pi.instance_id)
    end

    it "should return nil if not found" do
      pi = FactoryGirl.create(:provisioned_instance, :provisioned_version=>@pv)
      found = @pv.find_instance(pi.instance_id+"_notfound")
      found.should eq(nil)
    end
  end

  describe "#find_for_project" do
    it "should find the provisioned version" do
      @pv.save!
      found = ProvisionedVersion.find_for_project(@pv.project_id, @pv.version, @pv.environment)
      found.should_not eq(nil)
      found.id.should eq(@pv.id)
    end

    it "should return nil if not found" do
      @pv.save!
      found = ProvisionedVersion.find_for_project(@pv.project_id, @pv.version, @pv.environment+"_notfound")
      found.should eq(nil)
    end
  end

end
