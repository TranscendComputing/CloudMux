#
# Captures api actions for a user's cloud account
#
class QueueItem
  # Mongoid Mappings
  include Mongoid::Document
  field :action, type:String
  field :caller, type: String
  field :data, type:Hash
  field :errors, type:Hash
  field :create, type:DateTime, default: Time.now
  field :complete, type:DateTime

  def as_json(options)
    return self.attributes
  end

  def to_json
    return self.attributes.to_json
  end
end
