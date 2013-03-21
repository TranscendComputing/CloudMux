#
# Represents an Account's role within a project. Typical roles include: owner, member
#
class Member
  OWNER = 'owner'
  MEMBER = 'member'

  include Mongoid::Document

  embedded_in :project
  belongs_to :account
  embeds_many :permissions
  field :role, type:String
  field :last_opened_at, type:Time

  validates_presence_of :account_id
  validates_presence_of :role
end
