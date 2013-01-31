class NodeLink
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :node

  field :source_id, type:String
  field :target_id, type:String
end
