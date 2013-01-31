require 'service_spec_helper'

describe UpdateAccountRepresenter do

  before :each do
    @account = FactoryGirl.build(:account)
  end

  describe "#to_json" do
    it "should export to json" do
      @account.extend(UpdateAccountRepresenter)
      @account.password = "testing1234"
      result = @account.to_json
      result.should eq("{\"account\":{\"login\":\"#{@account.login}\",\"email\":\"#{@account.email}\",\"country_code\":\"United States\",\"password\":\"#{@account.password}\"}}")
    end
  end

end
