require 'service_spec_helper'

describe UpdateStackRepresenter do

  before :each do
    @stack = FactoryGirl.build(:stack)
    @stack.description = "a test stack"
  end

  describe "#to_json" do
    it "should export to json" do
      @stack.extend(UpdateStackRepresenter)
      result = @stack.to_json
      result.should eq("{\"stack\":{\"name\":\"#{@stack.name}\",\"description\":\"#{@stack.description}\"}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"stack\":{\"name\":\"#{@stack.name}\",\"description\":\"#{@stack.description}\"}}"
      new_stack = Stack.new
      new_stack.extend(UpdateStackRepresenter)
      new_stack.from_json(json)
      new_stack.name.should eq(@stack.name)
      new_stack.description.should eq(@stack.description)
    end
  end
end
