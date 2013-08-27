class PolicyRule
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :group_policies
  
  field :who, type:String
  field :what, type:String
  field :action, type:String
end
