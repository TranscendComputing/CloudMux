module QueueItemRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :account_id
  property :action
  property :data
  property :cred_id
  hash :errors
  property :create
  property :complete
end

