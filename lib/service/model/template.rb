#
# Represents a Template that may or may not be part of an existing
# stack. A template may only belong to a single stack, but may be
# watched/liked.
#
# If a template is not associated to a stack, it was likely uploaded
# anonymously and may be deleted after a specific period of time
# (TBD). Anonymous templates may be published, meaning they are
# associated to an account's stack.
#
# If a template belongs to a stack, then it can only be forked
# (future) or watched (future), but cannot be claimed.
#
# Currently we support only AWS CloudFormation templates, but future
# implementations may expand this
#
class Template
  CLOUD_FORMATION = "cloud_formation"

  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type:String
  field :template_type, type:String, default:CLOUD_FORMATION
  field :import_source, type:String
  field :raw_json, type:String
  belongs_to :stack

  # Validation Rules
  validates_presence_of :name
  validates_presence_of :template_type
  validates_presence_of :raw_json
  validate :must_be_valid_json

  def published?
    return (!stack.nil?)
  end

  def must_be_valid_json
    return false if raw_json.nil? or raw_json.empty?
    begin
      JSON.parse(raw_json)
      return true
    rescue JSON::ParserError => e
      errors.add(:raw_json, "Invalid JSON format")
      return false
    end
  end
end
