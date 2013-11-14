require 'service_spec_helper'

describe Org do
  before :each do
    @org = FactoryGirl.build(:org)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#initialize" do
    it "should initialize properly" do
      @org.should_not eq(nil)
    end
  end

  pending "#add_subscriber!" do
    before :each do
      @subscription = FactoryGirl.build(:subscription)
      @org.subscriptions << @subscription
      @account = FactoryGirl.build(:account, :login=>"standard_subscriber", :email=>"standard@example.com")
      @role = 'standard'
      @org.new?.should eq(true)
    end

    it "should save the org" do
      @org.add_subscriber!(@subscription.product, @account, @role)
      @org.new?.should eq(false)
    end

    it "should store a new subscriber" do
      @org.add_subscriber!(@subscription.product, @account, @role)
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(1)
      @org.subscriptions.first.subscribers.first.account.should eq(@account)
      @org.subscriptions.first.subscribers.first.role.should eq(@role)
    end

    it "should store a subscriber only once" do
      @org.add_subscriber!(@subscription.product, @account, @role)
      @org.add_subscriber!(@subscription.product, @account, @role)
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(1)
      @org.subscriptions.first.subscribers.first.account.should eq(@account)
      @org.subscriptions.first.subscribers.first.role.should eq(@role)
    end

    it "should update a subscriber if they exist" do
      @org.add_subscriber!(@subscription.product, @account, @role)
      @org.add_subscriber!(@subscription.product, @account, 'admin')
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(1)
      @org.subscriptions.first.subscribers.first.account.should eq(@account)
      @org.subscriptions.first.subscribers.first.role.should eq('admin')
    end

    it "should raise an exception if the product is not found" do
      lambda { @org.add_subscriber!(@subscription.product+"_not_found", @account, @role) }.should raise_error
    end
  end

  describe "#remove_subscriber!" do
    before :each do
      @subscription = FactoryGirl.build(:subscription)
      @org.subscriptions << @subscription
      @account = FactoryGirl.build(:account, :login=>"standard_subscriber", :email=>"standard@example.com")
      @role = 'standard'
      @org.add_subscriber!(@subscription.product, @account, @role)
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(1)
    end

    it "should remove the subscriber" do
      @org.remove_subscriber!(@subscription.product, @account)
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(0)
    end

    it "should ignore multiple removes" do
      @org.remove_subscriber!(@subscription.product, @account)
      @org.remove_subscriber!(@subscription.product, @account)
      @org.subscriptions.length.should eq(1)
      @org.subscriptions.first.subscribers.length.should eq(0)
    end

    it "should raise an exception if the product is not found" do
      lambda { @org.remove_subscriber!(@subscription.product+"_not_found", @account) }.should raise_error
    end
  end

end
