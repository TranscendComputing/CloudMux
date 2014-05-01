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
  property :rss_url
  property :num_logins
  collection :permissions, :class=>Permission, :extend => PermissionRepresenter
  collection :subscriptions, :class=>Account::AccountSubscription, :extend => AccountSubscriptionRepresenter
  collection :cloud_credentials, :class=>CloudCredential, :extend => CloudCredentialRepresenter
  collection :project_memberships, :class=>Account::ProjectMembership, :extend => ProjectMembershipRepresenter
  collection :group_policies, :class=>GroupPolicy, :extend => GroupPolicyRepresenter
end
