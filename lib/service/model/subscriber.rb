class Subscriber
  include Mongoid::Document

  embedded_in :subscription

  belongs_to :account
  field :role, type:String
end
