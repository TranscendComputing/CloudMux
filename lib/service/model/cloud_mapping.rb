#
# Stores mappings for a cloud or an organization. Mappings have a
# properties hash for storing additional details about the mapping
# (e.g. operating_system and backed_by for server image maps), and
# mapping_entries that store an ordered list of hashes that contain
# the details for each map entry
#
class CloudMapping
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :mappable, polymorphic:true

  field :name, type:String
  field :mapping_type, type:String
  field :submitted_by, type:String
  field :properties, type:Hash
  field :mapping_entries, type:Array

  # Validation Rules
  validates_presence_of :name

end
