module UpdatePermissionRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :permission

  property :name
  property :environment
end
