require 'service_spec_helper'

describe CloudMapping do
  before :each do
    @cloud_account = FactoryGirl.build(:cloud_account)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#properties" do
    it "should store and provide access as required" do
      @map = FactoryGirl.build(:cloud_mapping)
      @map.properties = { }
      @map.properties['operating_system'] = "Windows"
      @cloud_account.cloud_mappings << @map
      @cloud_account.save!
      @cloud_account.reload
      @cloud_account.cloud_mappings.length.should eq(1)
      @cloud_account.cloud_mappings.first.properties['operating_system'].should eq("Windows")
    end
  end

  describe "#mapping_entries" do
    it "should store and provide access as required" do
      @map = FactoryGirl.build(:cloud_mapping)
      @map.mapping_entries = []
      entry_1 = { "image_ami_id"=>"ami-4b814f22", "region"=>"us-east-1", "region_name"=>"US East"}
      entry_2 = { "image_ami_id"=>"ami-bb3b06cf", "region"=>"eu-west-1", "region_name"=>"Europe"}
      @map.mapping_entries << entry_1
      @map.mapping_entries << entry_2
      @cloud_account.cloud_mappings << @map
      @cloud_account.save!
      @cloud_account.reload
      @cloud_account.cloud_mappings.length.should eq(1)
      mapping = @cloud_account.cloud_mappings.first
      mapping.mapping_entries.length.should eq(2)
      mapping.mapping_entries.first["image_ami_id"].should eq(entry_1["image_ami_id"])
    end
  end
end
