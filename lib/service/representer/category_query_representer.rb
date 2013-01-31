module CategoryQueryRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  # self.representation_wrap = true

  property :query, :class=>Query, :extend => QueryRepresenter
  collection :categories, :class=>Category, :extend => CategoryRepresenter
end
