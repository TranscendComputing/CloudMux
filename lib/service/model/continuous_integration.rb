class ContinuousIntegration
    include Mongoid::Document

    belongs_to :org
    has_and_belongs_to_many :config_manager

    field :type
    field :host
    field :port
    field :username
    field :password
end