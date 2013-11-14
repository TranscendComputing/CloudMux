require 'service_spec_helper'

describe Stack do
  before :each do
    @account = FactoryGirl.create(:account)
    @stack = FactoryGirl.build(:stack, :account=>@account)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#initialize" do
    it "should initialize properly" do
      @stack.should_not eq(nil)
    end
  end

  # Believe this functionality is no longer active.
  pending "#templates" do
    before :each do
      @stack.save!
      @template = FactoryGirl.build(:template, :stack=>@stack)
      @template.save!
    end

    it "should set a template's stack reference when added" do
      last_template = Template.last
      last_template.should_not eq(nil)
      last_template.stack.id.should eq(@stack.id)
    end

    it "should add the template to the stack" do
      @stack.reload
      @stack.templates.length.should eq(1)
    end
  end

  describe "#valid?" do
    it "should require properly name field" do
      @stack.valid?.should eq(true)
      @stack.name = nil
      @stack.valid?.should eq(false)
    end
  end

  # Believe this functionality is no longer active.
  pending "#publish!" do
    it "should default to private" do
      Stack.new.public?.should eq(false)
    end

    it "should be set to public when called" do
      @stack.publish!
      @stack.public?.should eq(true)
    end
  end

  # Believe this functionality is no longer active.
  pending "#set_permalink" do
    it "should not set the permalink if the account is nil" do
      @stack.account = nil
      @stack.save!
      @stack.permalink.should eq(nil)
    end

    it "should not set the permalink if one is already set" do
      @stack.permalink = "mine"
      @stack.save!
      @stack.permalink.should eq("mine")
    end

    it "should set the permalink on save" do
      @stack.save!
      @stack.reload
      @stack.permalink.should eq("test/test-stack")
    end
  end

  # Believe this functionality is no longer active.
  pending "#find_by_permalink" do
    it "should find by permalink" do
      @stack.save!
      @stack.permalink.should_not eq(nil)
      found = Stack.find_by_permalink(@stack.permalink)
      found.id.should eq(@stack.id)
    end

    it "return nil if not found by permalink" do
      @stack.save!
      @stack.permalink.should_not eq(nil)
      found = Stack.find_by_permalink(@stack.permalink+"_fake")
      found.should eq(nil)
    end
  end

  # Believe this functionality is no longer active.
  pending "#resource_groups" do
    it "should default to an empty array" do
      @stack.save!
      @stack.resource_groups.should_not eq(nil)
      @stack.resource_groups.empty?.should eq(true)
    end

    it "should store an array of values" do
      a = ["a", "b", "c"]
      @stack.resource_groups = a
      @stack.save!
      @stack.reload
      @stack.resource_groups.should eq(a)
    end
  end

  # Believe this functionality is no longer active.
  pending "#update_resource_groups!" do
    it "should set an empty array if no templates are attached to the stack" do
      @stack.templates.length.should eq(0)
      @stack.update_resource_groups!
      @stack.resource_groups.length.should eq(0)
    end

    it "should store the resource groups for an attached template" do
      json = file("spec/cfdoc_fixtures/careers_formation.json")
      expected_resources = %W{auto_scaling compute identity monitoring notification}
      @template = FactoryGirl.create(:template, :stack=>@stack, :raw_json=>json)
      @stack.templates.length.should eq(1)
      @stack.update_resource_groups!
      @stack.resource_groups.length.should eq(5)
      @stack.resource_groups.should eq(expected_resources)
    end
  end

end
