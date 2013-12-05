module QueueItemRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :account_id
  property :action
  hash :parameters
  hash :errors
  hash :results
  property :run
  property :completed
end

