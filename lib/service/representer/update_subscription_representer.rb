module UpdateSubscriptionRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :subscription

  property :billing_level
  property :billing_subscription_id
  property :billing_customer_id
end
