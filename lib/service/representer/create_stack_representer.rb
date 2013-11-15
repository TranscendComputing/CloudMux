module CreateStackRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  property :name
  property :description
  property :account_id
  property :template
end
