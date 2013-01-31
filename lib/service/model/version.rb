#
# Represents a version entry for a StackStudio Project
#
class Version
  CURRENT = 'current'
  INITIAL = '0.1.0'

  VERSION_REGEX = /^(\d)+\.?(\d)+\.?(\*|\d+)$/

  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps # for storing when the version was created

  embedded_in :versionable, polymorphic:true

  field :number, type:String
  field :description, type:String
  
  embeds_many :environments # for determining which environments are available for a project version

  validates_presence_of :number
  validate :validate_format
  
  # assign a new Environment with the name "development" on create
  after_create :create_dev_environment  

  def validate_format
    return if number == CURRENT
    m = number.match(VERSION_REGEX)
    if !m
      errors.add(:number, "format must be major.minor.micro")
    end
  end

  def validate_version_number(existing_versions)
    return true if number == CURRENT
    return if errors[:number].length > 0 # skip if it didn't pass the format check
    # no existing versions
    return true if existing_versions.nil? or existing_versions.empty?

    current = split
    last = existing_versions.last.split

    # major number incremented
    return true if current[0] > last[0]
    # minor number incremented
    return true if current[0] == last[0] and current[1] > last[1]
    # micro number incremented
    return true if current[0] == last[0] and current[1] == last[1] and current[2] > last[2]

    # validation failed
    errors.add(:number, "new version number #{number} must be greater than #{existing_versions.last.number}")
    return false
  end

  # splits the version number into an array of three integers
  def split
    m = number.match(VERSION_REGEX)
    (m.nil? ? nil : m[1..3].map { |s| s.to_i })
  end
  
  
  # when a new version is created, create a default, dev environment
  def create_dev_environment
    if self.environments.empty?
      self.environments << Environment.new(:name=>Environment::DEV)
    end
  end 
  
end
