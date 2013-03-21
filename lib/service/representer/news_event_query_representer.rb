module NewsEventQueryRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  # self.representation_wrap = true

  property :query, :class=>Query, :extend => QueryRepresenter
  collection :news_events, :class=>NewsEvent, :extend => NewsEventRepresenter
end
