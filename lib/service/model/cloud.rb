#
# Captures details about available clouds
#
class Cloud
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type:String
  field :cloud_provider, type:String
  field :public, type:Boolean, default:true
  field :permalink, type:String

  index :permalink, :unique=>true
  index :public

  # Validation Rules
  validates_presence_of :name

  # Scopes
  scope :public_clouds, where(public:true)

  before_save :set_permalink

  def self.find_by_permalink(perma)
    return nil if perma.nil? or perma.empty?
    return self.find(:first, :conditions=>{ :permalink=>perma})
  end

  def set_permalink
    self.permalink = self.name.to_permalink if self.permalink.blank?
  end
end
