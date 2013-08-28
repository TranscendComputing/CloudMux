class GroupPolicy
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :org
  
  has_and_belongs_to_many :policy_rules
  has_many :groups
  
  field :name, type:String
end
