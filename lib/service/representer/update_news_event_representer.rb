module UpdateNewsEventRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :description
  property :url
  property :source
  property :posted

end
