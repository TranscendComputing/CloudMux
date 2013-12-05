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
end
