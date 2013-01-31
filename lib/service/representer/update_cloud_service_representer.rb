module UpdateCloudServiceRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :service_type
  property :path
  property :protocol
  property :host
  property :port
  property :enabled
end
