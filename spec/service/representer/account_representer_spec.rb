require 'service_spec_helper'

describe AccountRepresenter do

  before :each do
    @account = FactoryGirl.build(:account)
  end

  describe "#to_json" do
    it "should export to json" do
      @account.extend(AccountRepresenter)
      result = @account.to_json
      result.should eq("{\"account\":{\"id\":\"#{@account.id}\",\"login\":\"#{@account.login}\",\"email\":\"#{@account.email}\",\"num_logins\":0,\"permissions\":[],\"subscriptions\":[],\"cloud_credentials\":[],\"project_memberships\":[],\"group_policies\":[]}}")
    end
  end

  describe "#from_json" do
    it "should import from json" do
      json = "{\"account\":{\"id\":\"#{@account.id}\",\"login\":\"#{@account.login}\",\"email\":\"#{@account.email}\"}}"
      new_account = Account.new.extend(AccountRepresenter)
      new_account.from_json(json)
      new_account.id.should eq(@account.id)
      new_account.login.should eq(@account.login)
      new_account.email.should eq(@account.email)
    end
  end

end
