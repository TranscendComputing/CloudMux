require 'service_spec_helper'

describe CreateStack do
  before :each do
    @account = FactoryGirl.create(:account)
    @template = FactoryGirl.create(:template)
    @category = FactoryGirl.create(:category)
    @create_stack = FactoryGirl.build(:create_stack, :account_id=>@account.id, :template_id=>@template.id, :category_id=>@category.id)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#valid?" do
    it "should require name" do
      @create_stack.valid?.should eq(true)
      @create_stack.name = nil
      @create_stack.valid?.should eq(false)
    end

    it "should require account_id" do
      @create_stack.valid?.should eq(true)
      @create_stack.account_id = nil
      @create_stack.valid?.should eq(false)
    end
  end

  describe "#account_must_exist" do
    it "should return true if found" do
      @create_stack.account_must_exist.should eq(true)
    end

    it "should add an error if not found" do
      @create_stack.account_id = "4f7b1405be8a7c3fc8000004"
      @create_stack.account_must_exist.should eq(false)
      @create_stack.errors[:account_id].length.should eq(1)
      @create_stack.errors[:account_id][0].should eq("not found")
    end

    it "should add an error if the id is an invalid format" do
      @create_stack.account_id = "abc"
      @create_stack.account_must_exist.should eq(false)
      @create_stack.errors[:account_id].length.should eq(1)
      @create_stack.errors[:account_id][0].should eq("invalid")
    end
  end

  describe "#template_must_exist" do
    it "should return true if found" do
      @create_stack.template_must_exist.should eq(true)
    end

    it "should add an error if not found" do
      @create_stack.template_id = "4f3d8a96be8a7c3caf000014"
      @create_stack.valid?.should eq(false)
      @create_stack.errors[:template_id].length.should eq(1)
      @create_stack.errors[:template_id][0].should eq("not found")
    end

    it "should add an error if the id is an invalid format" do
      @create_stack.template_id = "abc"
      @create_stack.valid?.should eq(false)
      @create_stack.errors[:template_id].length.should eq(1)
      @create_stack.errors[:template_id][0].should eq("invalid")
    end

    it "should add an error if the template is already published by another stack" do
      @create_stack.template_must_be_unpublished.should eq(true)
      @stack = FactoryGirl.create(:stack)
      @template.stack = @stack
      @template.save!
      @create_stack.template_must_be_unpublished.should eq(false)
      @create_stack.errors[:template_id].length.should eq(1)
      @create_stack.errors[:template_id][0].should eq("already associated to another stack")
    end
  end
end
