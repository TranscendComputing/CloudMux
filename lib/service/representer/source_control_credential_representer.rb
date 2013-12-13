module SourceControlCredentialRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = :source_control_credential

  property :id
  property :user, type:String
  property :password, type:String
  property :private_key, type:String
end
