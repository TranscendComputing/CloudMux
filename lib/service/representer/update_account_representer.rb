module UpdateAccountRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :account

  property :org_id
  property :login
  property :email
  property :first_name
  property :last_name
  property :company
  property :country_code

  property :password
end
