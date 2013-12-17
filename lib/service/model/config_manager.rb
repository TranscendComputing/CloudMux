class ConfigManager
	include Mongoid::Document
    
    belongs_to :org

    field :protocol, type:String
    field :host, type:String
    field :port, type:String
	field :path, type:String
	field :enabled, type:Boolean
    field :type, type:String
    field :name, type:String
    field :auth_properties, type:Hash
    field :source_control_uri, type:String
    field :branch, type:String
    field :source_control_paths, type:Array

    has_and_belongs_to_many :cloud_accounts
    has_and_belongs_to_many :continuous_integration_servers
    has_one :source_control_credential
end