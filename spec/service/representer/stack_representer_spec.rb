require 'service_spec_helper'

describe StackRepresenter do

  before :each do
    @stack = FactoryGirl.create(:stack, :resource_groups=>["group1", "group2", "group 3"])
    @template = FactoryGirl.create(:template, :stack=>@stack)
  end

  describe "#to_json" do
    it "should export to json" do
      @stack.extend(StackRepresenter)
      result = @stack.to_json
      result.should eq("{\"stack\":{\"id\":\"#{@stack.id}\",\"name\":\"Test stack\",\"public\":true,\"downloads\":0,\"created_at\":\"#{@stack.created_at.iso8601}\",\"updated_at\":\"#{@stack.updated_at.iso8601}\",\"templates\":[{\"template\":{\"id\":\"#{@template.id}\",\"name\":\"Test template\",\"template_type\":\"cloud_formation\"}}],\"resource_groups\":[\"group1\",\"group2\",\"group 3\"]}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"stack\":{\"id\":\"#{@stack.id}\",\"name\":\"Test stack\",\"permalink\":\"test/test-stack\",\"public\":true,\"downloads\":0,\"created_at\":\"#{@stack.created_at.iso8601}\",\"updated_at\":\"#{@stack.updated_at.iso8601}\",\"templates\":[{\"template\":{\"id\":\"#{@template.id}\",\"name\":\"Test template\",\"template_type\":\"cloud_formation\"}}], \"account\":{},\"category\":{}}}"
      new_stack = Stack.new
      new_stack.extend(StackRepresenter)
      new_stack.from_json(json)
      new_stack.name.should eq(@stack.name)
      new_stack.templates.compact.length.should eq(1)
      new_stack.templates.first.name.should eq(@template.name)
      new_stack.account.should_not eq(nil)
    end
  end
end
