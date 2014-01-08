class ChefConfigurationManager < ConfigManager
  include Mongoid::Document

  embeds_many :cookbooks

  def add_cookbook!(cookbook)
    self.cookbooks << cookbook
    self.save!
  end 
end