module GroupRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :name
  property :description
  property :org_id
  property :group_policy, :class=>GroupPolicy, :extend=>GroupPolicyRepresenter
  collection :group_memberships, :class=>GroupMembership, :extend=>GroupMembershipRepresenter
end
