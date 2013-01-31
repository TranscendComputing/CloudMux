module SubscriberRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  # self.representation_wrap = :subscriber

  property :account, :class=>Account, :extend => AccountSummaryRepresenter
  property :role
end
