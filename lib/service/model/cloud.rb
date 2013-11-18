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

  index({permalink:1}, {unique:true})
  index({public:1})

  # Validation Rules
  validates_presence_of :name

  # Scopes
  scope :public_clouds, where(public:true)

  before_save :set_permalink

  def self.find_by_permalink(perma)
    return nil if perma.nil? or perma.empty?
    begin
      return self.find_by(permalink:perma)
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end

  def set_permalink
    self.permalink = self.name.to_permalink if self.permalink.blank?
  end
end
