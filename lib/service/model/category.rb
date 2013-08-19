#
# Simple categorization for stacks
#
class Category
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type:String
  field :permalink, type:String
  field :description, type:String

  index({permalink:1},{unique:true})

  # Validation Rules
  validates_presence_of :name

  before_save :set_permalink

  def self.find_by_permalink(perma)
    return nil if perma.nil? or perma.empty?
    return self.find_by(permalink:perma)
  end

  def set_permalink
    self.permalink = self.name.to_permalink if self.permalink.blank?
  end
end
