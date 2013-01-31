#
# Represents the specific version for a StackStudio Project 
#
class ProjectVersion
  CURRENT = Version::CURRENT
  INITIAL = Version::INITIAL
  # status
  ACTIVE = 'active'
  ARCHIVED = 'archived'

  # Mongoid Mappings
  include Mongoid::Document

  belongs_to :project
  field :version, type:String
  field :status, type:String, default:ACTIVE

  # element and node support
  embeds_many :elements
  embeds_many :nodes
  
  # SDLC environment variant support
  embeds_many :variants, :as=>:variantable # Variant
  #embeds_many :environments, :as=>:environmentable, :class_name => 'Environment' # Environment

  # Embedded project support
  embeds_many :embedded_projects

  # Indexes
  index :status
  index([ [ :project_id, Mongo::ASCENDING ],  [ :version, Mongo::ASCENDING ] ])
  
  # Validation Rules
  validate :validate_version_active
  
  #
  # -- Status Support
  #

  def active!
    self.update_attribute(:status, ACTIVE)
  end
  def active?
    return (self.status == ACTIVE)
  end

  def archive!
    self.update_attribute(:status, ARCHIVED)
  end
  def archived?
    return (self.status == ARCHIVED)
  end

  def validate_version_active
    errors.add(:status, "is not an active version") unless active?
  end

  def self.find_for_project(project_id, version_id)
    self.find(:first, :conditions=>{ :project_id=>project_id.to_s, :version=>version_id.to_s})
  end

  def find_element(element_id)
    elements.select { |e| e.id.to_s == element_id.to_s }.first
  end

  def find_node(node_id)
    nodes.select { |n| n.id.to_s == node_id.to_s }.first
  end

  def find_variant(variant_id)
    variants.select { |v| v.id.to_s == variant_id.to_s }.first
  end

  def remove_variant_for!(environment)
    found = variants.select { |v| v.environment == environment }.first
    found.delete if found
  end

  def find_embedded_project(embedded_project_id)
    embedded_projects.select { |e| e.id.to_s == embedded_project_id.to_s }.first
  end

  #
  # -- Environment Support
  #

  # retrieves the associated cloud account to be used by the project for provisioning
  def environments
    project_version = self.project.versions.where(number: self.version).first
    if project_version.nil?
        return nil
    else
        return project_version.environments
    end
  end 

  # promotes adds the new environment to the project_version's envrionments list
  def promote!(environment)
    environments << environment
    self.project.save!
  end
  
end
