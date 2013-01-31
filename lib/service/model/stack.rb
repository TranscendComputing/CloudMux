#
# Represents an architectural stack, including templates and other
# artifacts necessary to define and compose the stack
#
class Stack
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type:String
  field :description, type:String
  field :support_details, type:String
  field :license_agreement, type:String
  field :image_name, type:String
  field :image_data, type:Binary
  field :permalink, type:String
  field :public, type:Boolean, default: false
  field :downloads, type:Integer, default: 0
  field :resource_groups, type:Array, default: []
  belongs_to :account
  belongs_to :category
  has_many :templates

  index :public
  index :permalink, :unique=>true
  index([ [ :permalink, Mongo::ASCENDING ], [ :public, Mongo::ASCENDING ] ])
  index([[:created_at, Mongo::DESCENDING]])
  index :category

  # Validation Rules
  validates_presence_of :name

  before_save :set_permalink

  def self.find_by_permalink(perma)
    return nil if perma.nil? or perma.empty?
    return self.find(:first, :conditions=>{ :permalink=>perma})
  end

  def set_permalink
    self.permalink = "#{account.login}/#{self.name.to_permalink}" if self.permalink.blank? and !self.account.nil?
  end

  def publish!
    self.update_attribute(:public, true)
  end

  def public?
    !!self.public
  end

  def downloaded!
    self.inc(:downloads, 1)
  end

  def update_resource_groups!
    groups = []
    self.templates.each do |template|
      parser = CFDoc::Parser::CFParser.new
      stack_template = parser.scan(template.raw_json)
      groups.concat(stack_template.resource_group_ids)
    end
    self.update_attribute(:resource_groups, groups.compact.uniq)
  end

  # load only specific fields for speed and to ignore the raw template
  # JSON that is part of the model - should match the associated
  # representer to ensure all fields required by the presenter are selected
  def template_summaries
    self.templates.only(:id, :name, :template_type)
  end

  # simply for testing representers and API logic by using from_json
  def template_summaries=(list)
    self.templates = list.compact
  end
end
