class ContinuousIntegrationServer
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :org, :foreign_key => 'org_id'
    has_and_belongs_to_many :config_managers

    attr_readonly :org_id
    attr_accessible :org_id, :name, :type, :url, :username, :password, :config_manager_ids

    # Validation Rules
    validates_presence_of :name, :type, :url

    field :name
    field :type
    field :url
    field :username
    field :password

    def as_json
        {"continuous_integration_server"=>self.attributes}
    end

    def to_json
        {"continuous_integration_server"=>self.attributes}.to_json
    end
end