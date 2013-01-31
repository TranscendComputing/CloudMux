#
# Stores the details about a subscription for an account
#
class Subscription
  BASIC = 'basic'
  PRO = 'pro'
  ENTERPRISE = 'enterprise'

  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :org

  field :product, type:String
  field :billing_level, type:String # Chargify product_handle (set during product creation - should map to our constants for 'basic', 'pro', 'enterprise')
  field :billing_subscription_id, type:String # Chargify subscription id
  field :billing_customer_id, type:String # Chargify customer id

  validates_presence_of :product

  embeds_many :subscribers
end
