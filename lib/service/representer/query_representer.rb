module QueryRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  property :total
  property :page
  property :offset
  property :per_page

  collection :links, :class=>Link, :extend => LinkRepresenter
end
