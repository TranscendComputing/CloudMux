require 'cfdoc_spec_helper'

describe CFDoc::Model::ResourceSupport do
  before :each do
    @resource = CFDoc::Model::Resource.new("Test")
  end

  describe "#in_group?" do
    it "should return true if rule is matched" do
      @resource.fields = { "type"=>"AWS::IAM::User" }
      @resource.in_group?("identity").should eq(true)
      @resource.fields = { "type"=>"AWS::ElasticLoadBalancing::LoadBalancer" }
      @resource.in_group?("load_balancing").should eq(true)
      @resource.fields = { "type"=>"AWS::AutoScaling::AutoScalingGroup" }
      @resource.in_group?("auto_scaling").should eq(true)
    end

    it "should return false if no rule is matched" do
      @resource.fields = { "type"=>"AWS::IAM::User" }
      @resource.in_group?("load_balancing").should eq(false)
    end
  end

  describe "#calc_group" do
    it "should return details for group" do
      @resource.fields = { "type"=>"AWS::IAM::User" }
      result = @resource.calc_group
      result.should_not eq(nil)
      result[CFDoc::Model::ResourceSupport::ID].should eq("identity")
      result[CFDoc::Model::ResourceSupport::DISPLAY_NAME].should eq("Identity")
    end

    it "should return other group if no rule is matched" do
      @resource.fields = { "type"=>"FakeType" }
      result = @resource.calc_group
      result.should_not eq(nil)
      result[CFDoc::Model::ResourceSupport::ID].should eq("other")
    end
  end

end
