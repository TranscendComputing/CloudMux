module NodeRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :name
  property :x
  property :y
  property :view
  property :element_id
  property :properties
  collection :node_links, :class=>NodeLink, :extend=>NodeLinkRepresenter
end
