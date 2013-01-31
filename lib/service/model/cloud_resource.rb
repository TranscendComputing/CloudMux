class CloudResource
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :cloud_account

  field :physical_id, type:String
  field :properties, type:Hash
end
