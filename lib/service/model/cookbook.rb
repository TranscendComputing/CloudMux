class Cookbook
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :chef
  
  field :name, type:String
  field :community, type:Boolean
  field :ci_presence, type:Boolean
  field :status, type:Hash
  
  validates_presence_of :name
end
