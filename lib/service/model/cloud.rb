#
# Captures details about available clouds
#
class Cloud
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :cloud_services
  embeds_many :prices
  embeds_many :cloud_mappings, :as=>:mappable # CloudMapping

  field :permalink, type:String  
  field :name, type:String
  field :cloud_provider, type:String
  field :url, type:String
  field :protocol, type:String
  field :host, type:String
  field :port, type:String
  field :public, type:Boolean, default:true
  field :topstack_enabled, type:Boolean, default:false
  field :topstack_id, type:String

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
  
  def find_price(price_id)
	prices.select { |e| e.id.to_s == price_id.to_s }.first
  end

  def remove_service!(service_id)
    cloud_services.select { |s| s.id.to_s == service_id.to_s }.each { |s| s.delete }
    self.save!
  end

  def remove_mapping!(mapping_id)
    cloud_mappings.select { |s| s.id.to_s == mapping_id.to_s }.each { |s| s.delete }
    self.save!
  end
  
  def remove_price!(price_id)
	prices.select{ |s| s.id.to_s == price_id.to_s }.each { |s| s.delete }
  end
end
