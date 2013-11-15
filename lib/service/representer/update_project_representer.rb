module UpdateProjectRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :description
  property :project_type
  property :region
  property :cloud_credential_id
  property :owner_id
end
