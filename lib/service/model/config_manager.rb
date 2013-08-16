class ConfigManager
	include Mongoid::Document
    field :protocol, type:String
    field :host, type:String
    field :port, type:String
	field :path, type:String
	field :enabled, type:Boolean
    field :type, type:String
    field :name, type:String

    field :org

    field :auth_properties, type:Hash

    belongs_to :org
    has_and_belongs_to_many :cloud_accounts
end