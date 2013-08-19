class Country
  # Mongoid Mappings
  include Mongoid::Document

  field :code, type:String
  field :name, type:String

  index({code:1})

  def self.find_by_code(code)
    self.find_by(code:code)
  end
end
