class GroupPolicy
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :org
  
  has_and_belongs_to_many :policy_rules
  has_many :groups
  
  field :name, type:String
  field :aws_governance, type:Hash
  field :os_governance, type:Hash
  field :org_governance, type:Hash
end
