#
# Captures api actions for a user's cloud account
#
class QueueItem
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps
  field :action, type:String
  field :data, type:String
  field :cred_id, type: String
  field :errors, type:Hash
  field :create, type:DateTime, default: Time.now
  field :complete, type:DateTime
  belongs_to :account, :foreign_key => 'account_id'

  validates_presence_of :data

  def as_json(options)
    return self.attributes
  end

  def to_json
    return self.attributes.to_json
  end
end
