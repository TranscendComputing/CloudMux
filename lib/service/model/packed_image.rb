class PackedImage
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :org
  
  field :doc_id, type:String
  field :name, type:String
  field :image, type:Hash
end
