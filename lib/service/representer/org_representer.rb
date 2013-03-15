module OrgRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :org

  property :id
  property :name
  collection :accounts, :class=>Account, :extend => AccountRepresenter
  collection :cloud_accounts, :class=>CloudAccount, :extend => CloudAccountRepresenter
  collection :groups, :class=>Group, :extend => GroupRepresenter
  collection :subscriptions, :class=>Subscription, :extend => SubscriptionRepresenter
  collection :cloud_mappings, :class=>CloudMapping, :extend => CloudMappingRepresenter
end
