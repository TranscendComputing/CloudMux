module UpdateCloudAccountRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :description
  property :access_key
  property :secret_key
  property :cloud_attributes
  property :stack_preferences
  property :topstack_configured
end
