module UpdateNodeRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :x
  property :y
  property :view
  property :element_id
  property :properties
end
