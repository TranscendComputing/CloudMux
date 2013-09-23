class Stack
    # Mongoid Mappings
    include Mongoid::Document
    include Mongoid::Timestamps
  
    belongs_to :account, :foreign_key => 'account_id'
    field :name, type:String
    field :description, type:String
    field :compatible_clouds, type:Array, default: []
    field :template, type:String

    attr_readonly :account_id
    attr_accessible :account_id, :name, :description, :compatible_clouds, :template

    # Validation Rules
    validates_presence_of :name
    validate :must_be_valid_json

    def must_be_valid_json
        return false if template.nil? or template.empty?
        begin
            JSON.parse(template)
            return true
        rescue JSON::ParserError => e
            errors.add(:template, "Invalid JSON format")
            return false
        end
    end

    def as_json
        {"stack"=>self.attributes}
    end

    def to_json
        {"stack"=>self.attributes}.to_json
    end
end
