#
# Captures details about cloud credentials attached to a CloudAccount
#
class CloudCredential
  # Mongoid Mappings
  include Mongoid::Document

  belongs_to :cloud_account
  embedded_in :account
  embeds_many :audit_logs
  embeds_many :cloud_resources

  field :name, type:String
  field :description, type:String
  field :access_key, type:String
  field :secret_key, type:String
  field :cloud_attributes, type:Hash
  field :stack_preferences, type:Hash
  field :topstack_configured, type:Boolean, default:false

  def cloud_name
    (cloud_account.nil? ? nil : cloud_account.cloud_name)
  end
  def cloud_name=(name); end; # no-op: for the representer only
  
  def cloud_provider
  	(cloud_account.nil? ? nil : cloud_account.cloud_provider)
  end
  def cloud_provider=(name); end # no-op: for the representer only
  
  def topstack_enabled
  	(cloud_account.nil? ? nil : cloud_account.topstack_enabled)
  end
  def topstack_enabled=(name); end # no-op: for the representer only
  
  def topstack_id
  	(cloud_account.nil? ? nil : cloud_account.topstack_id)
  end
  def topstack_id=(name); end # no-op: for the representer only
end
