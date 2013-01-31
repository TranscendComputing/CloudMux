module UpdateOrgRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :org

  property :name
  collection :accounts, :class=>Account, :extend=>AccountRepresenter
end
