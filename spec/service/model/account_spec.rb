require 'service_spec_helper'

describe Account do
  before :each do
    @account = FactoryGirl.build(:account)
    Account.any_instance.stub(:bcrypt_cost).and_return(1)
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "#initialize" do
    it "should initialize properly" do
      @account.should_not eq(nil)
    end
  end

  describe "#find_by_login" do
    it "should find by login" do
      @account.save!
      found = Account.find_by_login(@account.login)
      found.should_not eq(nil)
      found.login.should eq(@account.login)
    end

    it "should find by email address" do
      @account.save!
      found = Account.find_by_login(@account.email)
      found.should_not eq(nil)
      found.login.should eq(@account.login)
    end
  end

  describe "#valid?" do
    it "should require login" do
      @account.valid?.should eq(true)
      @account.login = nil
      @account.valid?.should eq(false)
      @account.errors[:login].length.should eq(1)
    end

    it "should require email" do
      @account.valid?.should eq(true)
      @account.email = nil
      @account.valid?.should eq(false)
      @account.errors[:email].length.should eq(1)
    end

    it "should require a unique login" do
      @account.save!
      new_account = FactoryGirl.build(:account)
      new_account.valid?
      new_account.errors[:login].length.should eq(1)
      new_account.errors[:login][0].should eq("is already taken")
    end

    it "should be case insensitive for the unique login" do
      @account.save!
      new_account = FactoryGirl.build(:account, :login=>@account.login.upcase)
      new_account.valid?
      new_account.errors[:login].length.should eq(1)
      new_account.errors[:login][0].should eq("is already taken")
    end

    it "should require a unique email" do
      @account.save!
      new_account = FactoryGirl.build(:account)
      new_account.valid?
      new_account.errors[:email].length.should eq(1)
      new_account.errors[:email][0].should eq("is already taken")
    end

    it "should be case insensitive for the unique email" do
      @account.save!
      new_account = FactoryGirl.build(:account, :email=>@account.email.upcase)
      new_account.valid?
      new_account.errors[:email].length.should eq(1)
      new_account.errors[:email][0].should eq("is already taken")
    end
  end

  describe "#password=" do
    it "should set an encrypted password if a password is provided" do
      @account.password = 'test12345'
      @account.encrypted_password.should_not eq(nil)
    end

    it "should set a nil encrypted password if a password is not provided" do
      @account = FactoryGirl.build(:account, :password=>nil)
      @account.encrypted_password.should eq(nil)
    end

    it "should not set a nil encrypted password if an encrypted password is already set" do
      old_encrypted = @account.encrypted_password
      @account.password = nil
      @account.encrypted_password.should eq(old_encrypted)
    end
  end

  describe "#auth" do
    it "should return true if the password matches" do
      @account.password = 'test12345'
      @account.auth(@account.password).should eq(true)
    end

    it "should return false if the password doesn't match" do
      @account.password = 'test12345'
      @account.auth("test123451234").should eq(false)
    end

    it "should increment number of logins" do
      @account.num_logins.should eq(0)
      @account.password = 'test12345'
      @account.auth(@account.password)
      @account.num_logins.should eq(1)
    end

    it "should increment number of logins" do
      @account.last_login_at.should eq(nil)
      @account.password = 'test12345'
      now = Time.now
      @account.auth(@account.password, now)
      @account.last_login_at.to_s.should eq(now.to_s)
    end
  end

  describe "#country_code=" do
    it "should set the proper country if it is found" do
      country = @account.country
      account = Account.new
      account.country_code = country.code
      account.country.should eq(country)
    end

    it "should set the country as nil if it is not found" do
      country = @account.country
      account = Account.new
      account.country = nil
      account.country_code = country.code+"_test"
      account.country.should eq(nil)
    end
  end

  describe "#subscriptions" do
    before :each do
      @org = FactoryGirl.build(:org)
      @subscription_1 = FactoryGirl.build(:subscription, :product=>"test_1")
      @subscription_2 = FactoryGirl.build(:subscription, :product=>"test_2")
      @org.subscriptions << @subscription_1
      @org.subscriptions << @subscription_2
      @account_1 = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
      @account_2 = FactoryGirl.build(:account, :login=>"standard_subscriber_2", :email=>"standard_2@example.com")
      @role = 'standard'
      @org.new?.should eq(true)
    end

    it "should return subscriber instances associated to the specific account" do
      @account_1.subscriptions.count.should eq(0)
      @org.add_subscriber!(@subscription_1.product, @account_1, @role)
      @org.add_subscriber!(@subscription_2.product, @account_1, @role)
      @org.add_subscriber!(@subscription_1.product, @account_2, @role)
      @account_1.subscriptions.count.should eq(2)
      @account_1.subscriptions.first.class.should eq(Account::AccountSubscription)
      @account_1.subscriptions.first.org_id.should eq(@org.id.to_s)
      @account_1.subscriptions.last.class.should eq(Account::AccountSubscription)
      @account_2.subscriptions.count.should eq(1)
      @account_2.subscriptions.first.class.should eq(Account::AccountSubscription)
    end
  end

  describe "#cloud_credentials" do
    before :each do
      @cloud_credential = FactoryGirl.build(:cloud_credential)
      @account_1 = FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com")
      @account_1.cloud_credentials << @cloud_credential
      @account_1.save
    end

    it "should find cloud cloud_credential by id" do
      cloud_credential = Account.find_cloud_credential(@cloud_credential.id)
      cloud_credential.should_not eq(nil)
      cloud_credential.id.should eq(@cloud_credential.id)
    end
  end
end
