module TutorialStateRepresenter
	include Roar::Representer::JSON

	property :started
	collection :progress
	property :completed
	property :account_id
end