module ProvisionedInstancesRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  collection :instances, :class=>ProvisionedInstance, :extend=>UpdateProvisionedInstanceRepresenter
end
