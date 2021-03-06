class SourceControlRepository
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :org, :foreign_key => 'org_id'
    has_and_belongs_to_many :config_managers

    attr_readonly :org_id
    attr_accessible :org_id, :name, :type, :url, :username, :password, :key, :config_manager_ids

    # Validation Rules
    validates_presence_of :name, :type, :url

    field :name
    field :type
    field :url
    field :username
    field :password
    field :key

    def as_json
        {"source_control_repository"=>self.attributes}
    end

    def to_json
        {"source_control_repository"=>self.attributes}.to_json
    end
end