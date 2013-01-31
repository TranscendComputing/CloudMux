class GroupMembership
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :group
  belongs_to :account
  validates_presence_of :account_id
end
