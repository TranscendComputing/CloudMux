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

  # finds the account based on account id and returns it.
  def self.find_by_account(account)
     return nil if account.nil? or account.empty?
     return self.where(account_id:account).first
  end

  # deletes the resource tag.
  def self.delete_resource(resource)
    return nil if resource.nil? or resource.empty?
    self.where(resource_id:resource).first.destroy
  end

  # returns the tag count of a type of resource associated with an account.
  def self.count_resources(user_id,type)
    self.where(account_id:user_id,resource_type:type,operation:"create").count
  end
end