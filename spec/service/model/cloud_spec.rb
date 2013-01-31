require 'service_spec_helper'

describe Cloud do
  before :each do
    @cloud = FactoryGirl.build(:cloud)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#valid" do
    it "should require a name" do
      @cloud.valid?.should eq(true)
      @cloud.name = nil
      @cloud.valid?.should eq(false)
    end
  end

  describe "#before_save" do
    it "should not set the permalink if one is already set" do
      @cloud.permalink = "mine"
      @cloud.set_permalink
      @cloud.permalink.should eq("mine")
    end

    it "should set the permalink on save" do
      @cloud.set_permalink
      @cloud.permalink.should eq("my-public-cloud")
    end
  end

  describe "#public_clouds" do
    it "should scope to public clouds" do
      public_clouds = FactoryGirl.create_list(:cloud, 20)
      private_clouds = FactoryGirl.create_list(:cloud, 30, :public=>false)
      Cloud.public_clouds.count.should eq(public_clouds.length)
    end
  end

  describe "#remove_service!" do
    it "should remove an existing service" do
      @cloud.cloud_services = FactoryGirl.build_list(:cloud_service, 2)
      @cloud.save!
      @cloud.cloud_services.length.should eq(2)
      @cloud.remove_service!(@cloud.cloud_services.first.id)
      @cloud.reload
      @cloud.cloud_services.length.should eq(1)
    end

    it "should ignore if service not found" do
      @cloud.cloud_services = FactoryGirl.build_list(:cloud_service, 2)
      @cloud.save!
      @cloud.cloud_services.length.should eq(2)
      @cloud.remove_service!("4f7b1405be8a7c3fc8000004")
      @cloud.reload
      @cloud.cloud_services.length.should eq(2)
    end
  end

end
