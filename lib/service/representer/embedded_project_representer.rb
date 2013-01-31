module EmbeddedProjectRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :embedded_project_id
  property :embedded_project_name
  collection :variants, :class=>Variant, :extend=>VariantRepresenter
end
