#
# Captures details about resources associated with users
#
class UserResource
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account

  field :resource_id, type:String
  field :resource_type, type:String
  field :operation, type:String
  field :size, type:String

  index({account_id:1})

  def self.find_by_account(account)
     return nil if account.nil? or account.empty?
     return UserResource.where(account_id:account)
  end

end