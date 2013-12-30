class ConfigManager
	include Mongoid::Document
    include Mongoid::Timestamps
    
    belongs_to :org, :foreign_key => 'org_id'

    field :protocol, type:String
    field :url, type:String
	field :enabled, type:Boolean
    field :type, type:String
    field :name, type:String
    field :auth_properties, type:Hash
    field :branch, type:String
    field :source_control_paths, type:Array

    has_and_belongs_to_many :cloud_accounts
    has_and_belongs_to_many :continuous_integration_servers
    has_and_belongs_to_many :source_control_repositories

    def as_json
        attributes = get_attributes
        {"config_manager"=>attributes}
    end

    def to_json
        attributes = get_attributes
        {"config_manager"=>attributes}.to_json
    end

    def get_attributes
        attributes = self.attributes
        attributes["continuous_integration_servers"] = []
        attributes["source_control_repositories"] = []
        self.continuous_integration_servers.each{|ci| attributes["continuous_integration_servers"] << ci.as_json}
        self.source_control_repositories.each{|scr| attributes["source_control_repositories"] << scr.as_json}
        return attributes
    end
end