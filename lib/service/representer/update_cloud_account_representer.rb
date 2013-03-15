module UpdateCloudAccountRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :cloud_provider
  property :url
  property :protocol
  property :host
  property :port
  property :topstack_enabled
  property :topstack_id
end
