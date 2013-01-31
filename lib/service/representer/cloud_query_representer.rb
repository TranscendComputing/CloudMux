module CloudQueryRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  # self.representation_wrap = true

  property :query, :class=>Query, :extend => QueryRepresenter
  collection :clouds, :class=>Cloud, :extend => CloudRepresenter
end
