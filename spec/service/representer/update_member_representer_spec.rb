require 'service_spec_helper'
require 'spec/service/representer/member_representer_context'

describe UpdateMemberRepresenter do

  include_context "with a member"

  describe "#to_json" do
    it "should export to json" do
      member.extend(UpdateMemberRepresenter)
      result = member.to_json
      result.should eq("{\"member\":{\"account_id\":\"#{account_1.id}\",\"role\":\"#{member.role}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"member\":{\"account_id\":\"#{account_1.id}\",\"role\":\"#{member.role}\"}}"
      new_member = Member.new
      new_member.extend(UpdateMemberRepresenter)
      new_member.from_json(json)
      new_member.role.should eq(member.role)
      new_member.account_id.to_s.should eq(account_1.id.to_s)
    end
  end
end
