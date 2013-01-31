module GroupMembershipRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :account, :class=>Account, :extend=>AccountSummaryRepresenter
end
