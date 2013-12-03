#
# Captures api actions for a user's cloud account
#
class QueueItem
  # Mongoid Mappings
  include Mongoid::Document

  field :action, type:String
  field :parameters, type:Hash
  field :errors, type:Hash
  field :result, type:Hash
  field :run, type:DateTime, default: Time.now
  field :completed, type:DateTime
end
