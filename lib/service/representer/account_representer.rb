module AccountRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :org_id
  property :login
  property :email
  property :first_name
  property :last_name
  property :company
  collection :permissions, :class=>Permission, :extend => PermissionRepresenter
  collection :subscriptions, :class=>Account::AccountSubscription, :extend => AccountSubscriptionRepresenter
  collection :cloud_accounts, :class=>CloudAccount, :extend => CloudAccountRepresenter
  collection :project_memberships, :class=>Account::ProjectMembership, :extend => ProjectMembershipRepresenter
end
