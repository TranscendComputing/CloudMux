module UpdatePriceRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :name
  property :type
  property :effective_price
  property :effective_date
  property :properties
  property :entries
end