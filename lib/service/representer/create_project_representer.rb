module CreateProjectRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :description
  property :project_type
  property :cloud_account_id
  property :owner_id
  collection :with_environments
end
