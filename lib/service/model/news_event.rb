#
# Captures news event to display on StackStudio dashboard
#
class NewsEvent
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, type:String
  field :url, type:String
  field :source, type:String
  field :posted, type:Date

  index :url, :unique=>true

  # Validation Rules
  validates_presence_of :description
  validates_presence_of :url
  validates_presence_of :posted

end
