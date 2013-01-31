module CategorySummaryRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  property :id
  property :name
  property :permalink
  property :description
end
