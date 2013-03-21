require 'app_spec_helper'

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'stack_api_app')

include HttpStatusCodes

describe StackApiApp do
  def app
    StackApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "GET /" do
    before :each do
      @account = FactoryGirl.create(:account)
      @category_a = FactoryGirl.create(:category, :name=>"Category A")
      @category_b = FactoryGirl.create(:category, :name=>"Category B")
      FactoryGirl.create_list(:stack, 11, :account=>@account, :category=>@category_a)
      FactoryGirl.create_list(:stack, 19, :account=>@account, :category=>@category_b)
      @total = Stack.count
    end

    describe "defaults" do
      before :each do
        get "/"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return the first page of results by default" do
        @stack_query = StackQuery.new
        @stack_query.extend(StackQueryRepresenter)
        @stack_query.from_json(last_response.body)
        @stack_query.query.should_not eq(nil)
        @stack_query.stacks.length.should eq(20)
        @stack_query.query.offset.should eq(0)
        @stack_query.query.total.should eq(@total)
        @stack_query.query.page.should eq(1)
      end

      it "should contain links to the next page" do
        @stack_query = StackQuery.new
        @stack_query.extend(StackQueryRepresenter)
        @stack_query.from_json(last_response.body)
        @stack_query.query.links.length.should eq(1)
        @stack_query.query.links[0].rel.should eq('next')
      end
    end

    describe "pagination" do
      before :each do
        @page = 2
        get "/?page=#{@page}"
        @stack_query = StackQuery.new
        @stack_query.extend(StackQueryRepresenter)
        @stack_query.from_json(last_response.body)
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return the first page of results by default" do
        @stack_query.query.should_not eq(nil)
        @stack_query.stacks.length.should eq(10)
        @stack_query.query.offset.should eq(20)
        @stack_query.query.total.should eq(@total)
        @stack_query.query.page.should eq(2)
      end

      it "should contain link to the prev page" do
        @stack_query.query.links.length.should eq(1)
        @stack_query.query.links[0].rel.should eq('prev')
      end
    end

    describe "categories filter" do
      before :each do
        @categories = "#{@category_a.id.to_s}"
        get "/?categories=#{@categories}&per_page=10"
        @stack_query = StackQuery.new
        @stack_query.extend(StackQueryRepresenter)
        @stack_query.from_json(last_response.body)
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return the first page of results by default" do
        @stack_query.query.should_not eq(nil)
        @stack_query.stacks.length.should eq(10)
        @stack_query.query.offset.should eq(0)
        @stack_query.query.total.should eq(11)
        @stack_query.query.page.should eq(1)
      end

      it "should contain link to the next page" do
        @stack_query.query.links.length.should eq(1)
        @stack_query.query.links[0].rel.should eq('next')
        @stack_query.query.links[0].href.include?("&categories=#{@category_a.id}").should eq(true)
      end
    end
  end

  describe "GET /:id.json" do
    before :each do
      @account = FactoryGirl.create(:account)
      @category = FactoryGirl.create(:category)
      @stack = FactoryGirl.create(:stack, :account=>@account, :category=>@category)
      @template = FactoryGirl.create(:template, :stack=>@stack)
      get "/#{@stack.id}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid JSON payload" do
      stack = Stack.new.extend(StackRepresenter)
      stack.from_json(last_response.body)
      stack.id.should eq(@stack.id)
      stack.name.should eq(@stack.name)
      stack.description.should eq(@stack.description)
      stack.templates.length.should eq(2)
    end

    it "should return 404 if not found" do
      get "/#{@stack.id}notfound.json"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "GET /:user/:permalink.json" do
    before :each do
      @account = FactoryGirl.create(:account)
      @category = FactoryGirl.create(:category)
      @stack = FactoryGirl.create(:stack, :account=>@account, :category=>@category)
      @template = FactoryGirl.create(:template, :stack=>@stack)
      get "/#{@stack.permalink}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid JSON payload" do
      stack = Stack.new.extend(StackRepresenter)
      stack.from_json(last_response.body)
      stack.id.should eq(@stack.id)
      stack.name.should eq(@stack.name)
      stack.description.should eq(@stack.description)
      stack.templates.length.should eq(2)
    end

    it "should return 404 if not found" do
      get "/#{@stack.permalink}notfound.json"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "POST /" do
    before :each do
      @account = FactoryGirl.create(:account)
      @category = FactoryGirl.create(:category)
      @template = FactoryGirl.create(:template)
      @create_stack = FactoryGirl.build(:create_stack, :account_id=>@account.id.to_s, :template_id=>@template.id.to_s, :category_id=>@category.id).extend(CreateStackRepresenter)
      post "/", @create_stack.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid stack payload" do
      new_stack = Stack.new.extend(StackRepresenter)
      new_stack.from_json(last_response.body)
      new_stack.id.should_not eq(nil)
      new_stack.name.should eq(@create_stack.name)
    end

    it "should return the proper content type if data is missing" do
      @create_stack = FactoryGirl.build(:create_stack, :account_id=>@account.id, :template_id=>@template.id, :category_id=>@category.id, :name=>nil).extend(CreateStackRepresenter)
      post "/", @create_stack.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      @create_stack = FactoryGirl.build(:create_stack, :account_id=>@account.id, :template_id=>@template.id, :category_id=>@category.id, :name=>nil).extend(CreateStackRepresenter)
      post "/", @create_stack.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @template.reload
      @template.stack=nil
      @template.save!
      @template.published?.should eq(false)
      @create_stack = FactoryGirl.build(:create_stack, :account_id=>@account.id.to_s, :template_id=>@template.id.to_s, :category_id=>@category.id, :name=>nil).extend(CreateStackRepresenter)
      post "/", @create_stack.to_json
      @template.published?.should eq(false)
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end
  end

  describe "PUT /:id" do
    before :each do
      @account = FactoryGirl.create(:account)
      @category = FactoryGirl.create(:category)
      @stack = FactoryGirl.create(:stack, :account=>@account, :category=>@category).extend(UpdateStackRepresenter)
      @stack.name = "#{@stack.name}_new"
      put "/#{@stack.id}", @stack.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_stack = Stack.new.extend(StackRepresenter)
      updated_stack.from_json(last_response.body)
      updated_stack.name.should eq(@stack.name)
      updated_stack.description.should eq(@stack.description)
    end
  end
end
