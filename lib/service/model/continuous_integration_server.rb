class ContinuousIntegrationServer
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :org, :foreign_key => 'org_id'
    has_and_belongs_to_many :config_managers

    attr_readonly :org_id
    attr_accessible :org_id, :name, :type, :host, :protocol, :port, :username, :password, :config_manager_ids

    # Validation Rules
    validates_presence_of :name, :type, :host, :protocol, :port

    field :name
    field :type
    field :host
    field :protocol
    field :port
    field :username
    field :password

    def as_json
        attributes = get_attributes
        {"continuous_integration_server"=>attributes}
    end

    def to_json
        attributes = get_attributes
        {"continuous_integration_server"=>attributes}.to_json
    end

    def get_attributes
        attributes = self.attributes
        attributes["config_managers"] = []
        self.config_managers.each{|cm| attributes["config_managers"] << cm.as_json}
        return attributes
    end
end