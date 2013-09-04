class Portfolio
    # Mongoid Mappings
    include Mongoid::Document
    include Mongoid::Timestamps
  
    belongs_to :group, :foreign_key => 'group_id'
    field :name, type:String
    field :description, type:String
    field :version, type:String
    has_and_belongs_to_many :offerings

    attr_readonly :group_id
    attr_accessible :group_id, :name, :description, :version, :offerings

    # Validation Rules
    validates_presence_of :name

    def as_json
        attributes = get_attributes
        {"portfolio"=>attributes}
    end

    def to_json
        attributes = get_attributes
        {"portfolio"=>attributes}.to_json
    end

    def get_attributes
        attributes = self.attributes
        attributes["offerings"] = []
        self.offerings.each{|offering| attributes["offerings"] << offering.as_json}
        return attributes
    end
end
