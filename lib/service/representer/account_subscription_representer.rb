module AccountSubscriptionRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :subscription

  property :org_id
  property :org_name
  property :product
  property :billing_level
  property :role
end
