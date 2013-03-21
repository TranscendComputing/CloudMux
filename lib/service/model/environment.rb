#
# Represents a StackStudio Project Environment (i.e. SDLC variant)
#
class Environment
  DEV = 'development'
  TEST = 'test'
  STAGE = 'stage'
  PROD = 'production'
  
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :version

  field :name, type:String
  # depends on...
  # belongs_to :depends_on, :class_name=>"Environment"
  
  def validate_unique_environment(existing_environments)
    return false if existing_environments.nil?
    
    found = existing_environments.select { |e| e.name == name }.first
    if found
        errors.add(:name, "environment alread exists")
        return false
    else
        return true
    end
  end 
  
end
