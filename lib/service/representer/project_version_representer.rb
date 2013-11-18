module ProjectVersionRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :version
  collection :elements, :class=>Element, :extend=>ElementRepresenter
  collection :nodes, :class=>Node, :extend=>NodeRepresenter
  collection :variants, :class=>Variant, :extend=>VariantRepresenter
  collection :embedded_projects, :class=>EmbeddedProject, :extend=>EmbeddedProjectRepresenter
  #collection :environments, :class=>Environment, :extend=>EnvironmentRepresenter
end
