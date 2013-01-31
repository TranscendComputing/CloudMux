class Country
  # Mongoid Mappings
  include Mongoid::Document

  field :code, type:String
  field :name, type:String

  index :code

  def self.find_by_code(code)
    self.find(:first, :conditions=>{ :code=>code })
  end
end
