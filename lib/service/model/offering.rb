class Offering
    # Mongoid Mappings
    include Mongoid::Document
    include Mongoid::Timestamps
      
    belongs_to :account, :foreign_key => 'account_id'
    field :name, type:String
    field :version, type:String
    field :url, type:String
    field :sku, type:String
    field :icon, type:String
    field :illustration, type:String
    field :brief_description, type:String
    field :detailed_description, type:String
    field :eula, type:String
    field :eula_custom, type:String
    field :support, type:String
    field :pricing, type:String
    field :category, type:String
    has_and_belongs_to_many :stacks

    attr_readonly :account_id
    attr_accessible :account_id, :name, :version, :url, :sku, :icon, :illustration, :brief_description, :detailed_description, :eula, :eula_custom, :support, :pricing, :category, :stacks

    # Validation Rules
    validates_presence_of :name

    def as_json
        attributes = get_attributes
        {"offering"=>attributes}
    end

    def to_json
        attributes = get_attributes
        {"offering"=>attributes}.to_json
    end

    def get_attributes
        attributes = self.attributes
        attributes["stacks"] = []
        self.stacks.each{|s| attributes["stacks"] << stack.as_json}
        return attributes
    end
end
