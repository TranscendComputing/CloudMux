class Group
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :org
  
  embeds_many :group_memberships
  belongs_to :group_policy
  
  field :name, type:String
  field :description, type:String
  
  validates_presence_of :name
end
