#
# Represents a StackStudio project that manages templates, resources, and other associations.
#
# Projects operate under the following assumptions:
#
# 1. All projects have a "current" version number that is the current working version. This will always be the case
# 2. Freezing a version duplicates the current working version and assigns it a version. All embedded documents keep
#     the same ObjectId, enabling a smooth transition by the UI after a version is frozen. If this causes issues
#     with indexes or other things, this may need to be re-thought
# 3. Deleting an environment deletes the variant data from the "current" working version, but not past versions
# 4. Projects may be deleted or archived. Deleting them deletes everything, while archiving them prevents modifications (and therefore provisioning)
#
class Project
  # project_type
  STANDARD = 'standard'
  EMBEDDED = 'embedded'
  # status
  ACTIVE = 'active'
  ARCHIVED = 'archived'

  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :owner, :class_name=>"Account"#, :inverse_of=>:

  field :name, type:String
  field :description, type:String
  field :project_type, type:String, default:STANDARD
  field :region, type:String
  field :status, type:String, default:ACTIVE

  # ObjectId of the embedded cloud account for a user (can't reference it
  # directly, as it is embedded). If the cloud account is deleted or
  # the ID changes, this will no longer be valid
  field :cloud_credential_id, type:String

  # Membership support
  embeds_many :members
  
  # Group support
  embeds_many :group_projects

  # Templates, Versions
  embeds_many :versions, :as=>:versionable # Version

  # Project versions support
  has_many :project_versions, dependent: :delete

  # Project provisioning support
  has_many :provisioned_versions, dependent: :delete

  # indexes
  index({project_type:1})
  index({owner:1})
  index({status:1})
  index "members.account_id" =>1
  index "group_projects.group.group_memberships.account_id" => 1

  # Validation Rules
  validates_presence_of :name
  validates_associated :owner
  validate :validate_project_active

  # create a new owner membership entry by default
  after_create :create_owner_membership

  # assign a new ProjectVersion instance with the version "current" on create
  after_create :create_initial_version

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

  def validate_project_active
    errors.add(:status, "is not an active project") unless active?
  end

  def opened_by!(account_id, at=Time.now)
    # find the membership entry
    member = find_membership(account_id)
    # update the last_opened_at field
    if member
      member.update_attribute(:last_opened_at, at)
    end
  end

  #
  # -- Cloud Credential Support
  #

  # retrieves the associated cloud credential to be used by the project for provisioning
  def cloud_credential
    (self.cloud_credential_id.nil? ? nil : Account.find_cloud_credential(self.cloud_credential_id))
  end

  # stores the associated cloud credential to be used by the project for provisioning
  def cloud_credential=(cloud_credential)
    self.cloud_credential_id = (cloud_credential.kind_of?(String) ? cloud_credential : cloud_credential.id.to_s)
  end

  #
  # -- Members Support
  #

  def create_owner_membership
    member = Member.new(:account=>owner, :role=>Member::OWNER, :last_opened_at=>Time.now)
	member.permissions = []
	environments = [Environment::DEV, Environment::TEST, Environment::STAGE, Environment::PROD]
	environments.each do |e|
		member.permissions << Permission.new(:name => Permission::VIEW, :environment => e)
		member.permissions << Permission.new(:name => Permission::EDIT, :environment => e)
		member.permissions << Permission.new(:name => Permission::PUBLISH, :environment => e)
		member.permissions << Permission.new(:name => Permission::PROMOTE, :environment => e)
		member.permissions << Permission.new(:name => Permission::CREATE_STACK, :environment => e)
		member.permissions << Permission.new(:name => Permission::UPDATE_STACK, :environment => e)
		member.permissions << Permission.new(:name => Permission::DELETE_STACK, :environment => e)
		member.permissions << Permission.new(:name => Permission::MONITOR, :environment => e)
	end
    members << member
  end

  def find_membership(account_id)
    members.select { |m| m.account_id.to_s == account_id.to_s }.first
  end

  def remove_member!(member_id)
    members.select { |s| s.id.to_s == member_id.to_s }.each { |s| s.delete }
    self.save!
  end
  
  #
  # -- Member Permission Support
  #
  
  def add_member_permission!(member_id, permission)
	members.select { |m| m.id.to_s == member_id.to_s }.each do |member|
		member.permissions << permission
		member.save!
	end
  end
  
  def remove_member_permission!(member_id, permission_id)
	members.select { |m| m.id.to_s == member_id.to_s }.each do |member|
		member.permissions.select { |p| p.id.to_s == permission_id.to_s }.each { |p| p.delete }
	end
  end
  
  def remove_member_environment_permissions!(member_id, environment)
	members.select { |m| m.id.to_s == member_id.to_s }.each do |member|
		member.permissions.select { |p| p.environment.to_s == environment.to_s }.each { |p| p.delete }
	end
  end
  
  #
  # -- Group Support
  #
  
  def remove_group!(group_id)
    group_projects.select { |gp| gp.group_id.to_s == group_id.to_s }.each { |gp| gp.delete }
    self.save!
  end
  
  #
  # -- Group Permission Support
  #
  
  def add_group_permission!(group_id, permission)
	group_projects.select { |gp| gp.group_id.to_s == group_id.to_s }.each do |group_project|
		group_project.permissions << permission
		group_project.save!
	end
  end
  
  def remove_group_permission!(group_id, permission_id)
	group_projects.select { |gp| gp.group_id.to_s == group_id.to_s }.each do |group_project|
		group_project.permissions.select { |p| p.id.to_s == permission_id.to_s }.each { |p| p.delete }
	end
  end
  
  def remove_group_environment_permissions!(group_id, environment)
	group_projects.select { |gp| gp.group_id.to_s == group_id.to_s }.each do |group_project|
		group_project.permissions.select { |p| p.environment.to_s == environment.to_s }.each { |p| p.delete }
	end
  end

  #
  # -- Version Support
  #

  def create_initial_version
    if project_versions.empty?
      initial_version = Version.new
      initial_version.number = ProjectVersion::INITIAL
      initial_version.description = "Initial version"
      initial_version.versionable = self
      initial_version.save!
      project_versions << ProjectVersion.new(:version=>ProjectVersion::INITIAL)
    end
  end

  def current_version
    ProjectVersion.and({version:ProjectVersion::CURRENT},{project_id:self.id}).first
  end

  def freeze!(new_version, current_version_number)
    # add new version to self.versions
    new_version.versionable = self
    new_version.save!
    # clone the current ProjectVersion and assign the new version number, leaving the ObjectIds the same for embedded documents
    version_to_freeze = ProjectVersion.and({version:current_version_number},{project_id:self.id}).first
    cloned = version_to_freeze.dup
    cloned.version = new_version.number
    cloned.project = self
    cloned.save!
  end

end
