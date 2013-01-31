#
# Tracks a resource instance that belongs to a provisioned stack
#
class ProvisionedInstance
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :provisioned_version

  field :instance_type, type:String
  field :resource_id, type:String
  field :instance_id, type:String
  field :properties, type:Hash

  validates_presence_of :instance_type
  validates_presence_of :resource_id
  validates_presence_of :instance_id
end
