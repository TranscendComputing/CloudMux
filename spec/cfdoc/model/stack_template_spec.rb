require 'cfdoc_spec_helper'

describe CFDoc::Model::StackTemplate do
  before :each do
    @stack_template = CFDoc::Model::StackTemplate.new
    @stack_template.version = "1"
    @stack_template.description = "Example template"
  end

  describe "#initialize" do
  end

  describe "#<<" do
    it "should accept Element models and subclasses" do
      element = CFDoc::Model::Element.new("element")
      @stack_template << element
      @stack_template.elements.length.should eq(1)

      parameter = CFDoc::Model::Parameter.new("param")
      @stack_template << parameter
      @stack_template.elements.length.should eq(2)
    end

    it "should fail for other classes" do
      expect { @stack_template << "This is a string" }.to raise_error
    end
  end

  describe "#resource" do
    before :each do
      @element = CFDoc::Model::Element.new("element")
      @stack_template << @element
      @parameter = CFDoc::Model::Parameter.new("param")
      @stack_template << @parameter
      @resource = CFDoc::Model::Resource.new("resource")
      @stack_template << @resource
    end

    it "should return a resource by name" do
      @stack_template.resource(@resource.name).should eq(@resource)
    end

    it "should not return a non-resource by name" do
      @stack_template.resource(@element.name).should eq(nil)
    end

    it "should not return a non-resource by the same name as an existing resource" do
      @fake_resource = CFDoc::Model::Element.new("resource")
      @stack_template << @fake_resource
      @stack_template.resource(@resource.name).should eq(@resource)
    end
  end

  describe "#resources_in_group" do
    before :each do
      @resource_1 = CFDoc::Model::Resource.new("resource")
      @resource_1.fields = { "type"=>"AWS::IAM::User" }
      @stack_template << @resource_1
      @resource_2 = CFDoc::Model::Resource.new("resource")
      @resource_2.fields = { "type"=>"AWS::ElasticLoadBalancing::LoadBalancer" }
      @stack_template << @resource_2
      @resource_3 = CFDoc::Model::Resource.new("resource")
      @resource_3.fields = { "type"=>"AWS::AutoScaling::AutoScalingGroup" }
      @stack_template << @resource_3
    end

    it "should filter resources by type" do
      results = @stack_template.resources_in_group("identity")
      results.should_not eq(nil)
      results.length.should eq(1)
      results[0].should eq(@resource_1)
    end

  end

end
