module UpdateCloudRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :cloud_provider
  property :permalink
  property :public
end