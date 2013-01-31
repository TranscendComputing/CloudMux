module NodesRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  collection :nodes, :class=>Node, :extend=>UpdateNodeRepresenter
end
