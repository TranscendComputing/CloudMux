class Element
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :project_version

  field :name, type:String
  field :group_name, type:String
  field :element_type, type:String
  field :properties, type:String
end
