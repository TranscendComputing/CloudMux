#
# Captures details about source control credentials attached to a Config Manager.
#
class SourceControlCredential
  # Mongoid Mappings
  include Mongoid::Document

  belongs_to :config_manager

  field :user, type:String
  field :password, type:String
  field :private_key, type:String
end
