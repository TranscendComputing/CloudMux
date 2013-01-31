class Variant
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :variantable, polymorphic:true

  field :environment, type:String
  field :rule_type, type:String
  field :rules, type:Hash

  validates_presence_of :environment
  validates_presence_of :rule_type

end
