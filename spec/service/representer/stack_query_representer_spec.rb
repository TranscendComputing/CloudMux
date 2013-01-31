require 'service_spec_helper'

describe StackQueryRepresenter do

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  before :each do
    @account = FactoryGirl.create(:account)
    @stack = FactoryGirl.create(:stack, :account=>@account, :resource_groups=>["group1", "group2", "group 3"])
    @template = FactoryGirl.create(:template, :stack=>@stack)
    @query = FactoryGirl.build(:query)
    @stack_query = StackQuery.new
    @stack_query.query = @query
    @stack_query.stacks << @stack
    @query.links << Link.new("test1", "http://test.com/test1")
    @query.links << Link.new("test2", "http://test.com/test2")
  end

  describe "#to_json" do
    it "should export to json" do
      @stack_query.extend(StackQueryRepresenter)
      result = @stack_query.to_json
      result.should eq("{\"query\":{\"total\":504,\"page\":10,\"offset\":500,\"links\":[{\"rel\":\"test1\",\"href\":\"http://test.com/test1\"},{\"rel\":\"test2\",\"href\":\"http://test.com/test2\"}]},\"stacks\":[{\"stack\":{\"id\":\"#{@stack.id}\",\"name\":\"Test stack\",\"permalink\":\"test/test-stack\",\"public\":true,\"downloads\":0,\"created_at\":\"#{@stack.created_at.iso8601}\",\"updated_at\":\"#{@stack.updated_at.iso8601}\",\"account\":{\"id\":\"#{@account.id}\",\"login\":\"test\"},\"templates\":[{\"template\":{\"id\":\"#{@template.id}\",\"name\":\"Test template\",\"template_type\":\"cloud_formation\"}}],\"resource_groups\":[\"group1\",\"group2\",\"group 3\"]}}]}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"query\":{\"total\":504,\"page\":10,\"offset\":500,\"links\":[{\"rel\":\"test1\",\"href\":\"http://test.com/test1\"},{\"rel\":\"test2\",\"href\":\"http://test.com/test2\"}]},\"stacks\":[{\"stack\":{\"id\":\"#{@stack.id}\",\"name\":\"Test stack\",\"public\":true,\"created_at\":\"#{@stack.created_at.iso8601}\",\"updated_at\":\"#{@stack.updated_at.iso8601}\",\"account\":{},\"category\":{},\"templates\":[{\"template\":{\"id\":\"#{@template.id}\",\"name\":\"Test template\",\"template_type\":\"cloud_formation\"}}]}}]}"
      new_stack_query = StackQuery.new
      stacks = new_stack_query.stacks
      stacks.should_not eq(nil)
      stacks.length.should eq(0)
      new_stack_query.extend(StackQueryRepresenter)
      new_stack_query.from_json(json)
      new_stack_query.query.should_not eq(nil)
      new_stack_query.query.total.should eq(@query.total)
      stacks = new_stack_query.stacks
      stacks.first.name.should eq(@stack.name)
      stacks.first.templates.compact.length.should eq(1)
      stacks.first.templates.first.name.should eq(@template.name)
      new_stack_query.query.links.length.should eq(2)
      new_stack_query.query.links[0].rel.should eq("test1")
      new_stack_query.query.links[1].rel.should eq("test2")
    end
  end
end
