
class TutorialState

	include Mongoid::Document
	include Mongoid::Timestamps

	belongs_to :account, :foreign_key => 'account_id'
	field :started, type: Boolean, default: false
	field :completed, type: Boolean, default: false
	field :progress, type: Array
	field :account_id, type: String
	
end