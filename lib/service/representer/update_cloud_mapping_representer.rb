module UpdateCloudMappingRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :mapping_type
  property :submitted_by
  hash :properties
  collection :mapping_entries
end
