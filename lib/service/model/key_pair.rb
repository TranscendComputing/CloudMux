class KeyPair
  include Mongoid::Document
  belongs_to :cloud_credential
  field :name, type: String
  field :file, type: ::BSON::Binary
end