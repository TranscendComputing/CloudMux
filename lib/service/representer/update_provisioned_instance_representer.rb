module UpdateProvisionedInstanceRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :instance_type
  property :instance_id
  property :resource_id
  hash :properties
end
