module PermissionsRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  collection :permissions, :class=>Permission, :extend=>UpdatePermissionRepresenter
end
