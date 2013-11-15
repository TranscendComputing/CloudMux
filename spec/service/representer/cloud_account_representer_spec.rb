require 'service_spec_helper'

describe CloudAccountRepresenter do

  before :each do
    @cloud_account = FactoryGirl.build(:cloud_account)

    @org = FactoryGirl.build(:org)
    @org.save!
    @cloud = FactoryGirl.build(:cloud)
    @cloud.save!

    @org.reload
    @cloud.reload

    @cloud_account.org = @org
    @cloud_account.cloud = @cloud
    @cloud_account.cloud_services = FactoryGirl.build_list(:cloud_service, 2)
    @cloud_account.prices = FactoryGirl.build_list(:price, 2)
    @cloud_account.cloud_mappings = FactoryGirl.build_list(:cloud_mapping, 2)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#to_json" do
    it "should export to json" do
      @cloud_account.extend(CloudAccountRepresenter)
      result = @cloud_account.to_json
      expected = "{\"cloud_account\":{\"id\":\"#{@cloud_account.id}\",\"name\":\"#{@cloud_account.name}\",\"cloud_id\":\"#{@cloud_account.cloud_id}\",\"org_id\":\"#{@cloud_account.org_id}\",\"cloud_name\":\"#{@cloud_account.cloud_name}\",\"cloud_provider\":\"#{@cloud_account.cloud_provider}\",\"public\":#{@cloud_account.public},\"topstack_enabled\":true,\"topstack_id\":\"cloud_zone\",\"prices\":[{\"price\":{\"id\":\"#{@cloud_account.prices[0].id}\",\"name\":\"#{@cloud_account.prices[0].name}\",\"type\":\"#{@cloud_account.prices[0].type}\",\"effective_price\":#{@cloud_account.prices[0].effective_price},\"effective_date\":#{@cloud_account.prices[0].effective_date.to_json}}},{\"price\":{\"id\":\"#{@cloud_account.prices[1].id}\",\"name\":\"#{@cloud_account.prices[1].name}\",\"type\":\"#{@cloud_account.prices[1].type}\",\"effective_price\":#{@cloud_account.prices[1].effective_price},\"effective_date\":#{@cloud_account.prices[1].effective_date.to_json}}}],\"cloud_services\":[{\"cloud_service\":{\"id\":\"#{@cloud_account.cloud_services[0].id}\",\"service_type\":\"#{@cloud_account.cloud_services[0].service_type}\",\"path\":\"#{@cloud_account.cloud_services[0].path}\"}},{\"cloud_service\":{\"id\":\"#{@cloud_account.cloud_services[1].id}\",\"service_type\":\"#{@cloud_account.cloud_services[1].service_type}\",\"path\":\"#{@cloud_account.cloud_services[1].path}\"}}],\"cloud_mappings\":[{\"cloud_mapping\":{\"id\":\"#{@cloud_account.cloud_mappings[0].id}\",\"name\":\"#{@cloud_account.cloud_mappings[0].name}\",\"mapping_entries\":[]}},{\"cloud_mapping\":{\"id\":\"#{@cloud_account.cloud_mappings[1].id}\",\"name\":\"#{@cloud_account.cloud_mappings[1].name}\",\"mapping_entries\":[]}}]}}"
      result.should eq(expected)
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"cloud_account\":{\"id\":\"#{@cloud_account.id}\",\"name\":\"#{@cloud_account.name}\"}}"
      new_cloud = CloudAccount.new
      new_cloud.extend(CloudAccountRepresenter)
      new_cloud.from_json(json)
      new_cloud.name.should eq(@cloud_account.name)
      new_cloud.id.should eq(@cloud_account.id)
    end
  end
end
