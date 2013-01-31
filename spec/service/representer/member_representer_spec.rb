require 'service_spec_helper'

describe MemberRepresenter do

  before :each do
    @account_1 = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
    @member = FactoryGirl.build(:member, :account=>@account_1)
  end

  describe "#to_json" do
    it "should export to json" do
      @member.extend(MemberRepresenter)
      result = @member.to_json
      result.should eq("{\"member\":{\"id\":\"#{@member.id}\",\"account\":{\"id\":\"#{@account_1.id}\",\"login\":\"#{@account_1.login}\"},\"role\":\"#{@member.role}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"member\":{\"id\":\"#{@member.id}\",\"account\":{\"id\":\"#{@account_1.id}\",\"login\":\"#{@account_1.login}\"},\"role\":\"#{@member.role}\"}}"
      new_member = Member.new
      new_member.extend(MemberRepresenter)
      new_member.from_json(json)
      new_member.role.should eq(@member.role)
      new_member.id.should eq(@member.id)
      new_member.account.login.should eq(@member.account.login)
    end
  end
end
