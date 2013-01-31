module AddSubscriberRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :subscriber

  property :account_id
  property :role
end
