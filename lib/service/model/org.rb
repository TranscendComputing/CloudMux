#
# Represents an Organization, which has a subscription to one or more products
#
class Org
  include Mongoid::Document

  field :name, type:String
  has_many :accounts, dependent: :delete
  has_many :cloud_accounts, dependent: :delete
  has_many :groups, dependent: :delete
  has_many :config_managers, dependent: :delete
  has_many :group_policies, dependent: :delete
  
  embeds_many :subscriptions
  embeds_many :cloud_mappings, :as=>:mappable # CloudMapping

  validates_presence_of :name


  index "subscriptions.subscribers.account_id" => 1# see Account#subscriptions

  # -- Subscription support

  # finds a subscription by product name
  def product_subscription(product)
    self.subscriptions.select { |s| s.product == product }.first
  end

  # adds a new subscriber if the product is found and the account isn't already subscribed. Raises an exception if the product isn't found
  def add_subscriber!(product, account, role)
    subscription = product_subscription(product)
    if !subscription.nil?
      subscriber = subscription.subscribers.select { |s| s.account.id.to_s == account.id.to_s }.first
      if subscriber.nil?
        subscription.subscribers << Subscriber.new(:account=>account, :role=>role)
        self.save!
      else
        # update role in case it was upgraded or downgraded
        subscriber.role = role
        subscriber.save!
      end
    else
      raise "Product not found: #{product}"
    end
  end

  # removes an existing subscriber if the product is found and the account is already subscribed. Raises an exception if the product isn't found
  def remove_subscriber!(product, account)
    subscription = product_subscription(product)
    if !subscription.nil?
      matches = subscription.subscribers.select { |s| s.account.id.to_s == account.id.to_s }
      matches.each { |s| s.delete }
      subscription.save!
    else
      raise "Product not found: #{product}"
    end
  end
  
  def remove_group!(group_id)
	  groups.select { |g| g.id.to_s == group_id.to_s }.each { |g| g.delete }
	  self.save!
  end
  
  def add_account_to_group!(group_id, account_id)
	  groups.select { |g| g.id.to_s == group_id.to_s }.each do |group|
		  account = Account.find(account_id)
		  group.group_memberships << GroupMembership.new(:account=>account)
	  end
  end
  
  def remove_account_from_group!(group_id, account_id)
	  groups.select { |g| g.id.to_s == group_id.to_s }.each do |group|
		  group.group_memberships.select { |m| m.account.id.to_s == account_id.to_s }.each { |m| m.delete }
	  end
  end
  
  def find_mapping(mapping_id)
    cloud_mappings.select { |m| m.id.to_s == mapping_id.to_s }.first
  end 

  def remove_mapping!(mapping_id)
    cloud_mappings.select { |s| s.id.to_s == mapping_id.to_s }.each { |s| s.delete }
    self.save!
  end
end
