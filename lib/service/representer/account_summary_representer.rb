module AccountSummaryRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  # self.representation_wrap = true

  property :id
  property :org_id
  property :login
  property :first_name
  property :last_name
end
