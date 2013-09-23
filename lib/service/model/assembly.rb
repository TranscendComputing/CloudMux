class Assembly
  # Mongoid Mappings
  include Mongoid::Document

  field :name, type:String
  field :cloud, type:String
  field :configurations, type:Hash
  field :tool, type:String
  field :cloud_credential, type:String
  field :image, type:Hash
  belongs_to :account, :foreign_key=> 'account_id'

  attr_readonly :account_id
  attr_accessible :name, :cloud, :configurations, :account_id, :tool, :cloud_credential, :image

  #has_one :image

  def as_json(options)
      return self.attributes
  end

    def to_json
      return self.attributes.to_json
    end
end