class Price
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :cloud

  field :name, type:String
  field :type, type:String
  field :effective_price, type:Float
  field :effective_date, type:Time
  field :properties, type:Hash
  field :entries, type:Array
end
