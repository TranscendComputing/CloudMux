module GroupProjectRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :group, :class=>Group, :extend=>GroupRepresenter
  collection :permissions, :class=>Permission, :extend=>PermissionRepresenter
end
