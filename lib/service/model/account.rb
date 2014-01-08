require 'service/ldap'
#
# Represents a User Account that can be created, authenticated, and updated
#
class Account

  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  # transient field for setting password prior to encryption
  attr_accessor :password

  # basic fields
  field :email, type:String
  field :first_name, type:String
  field :last_name, type:String
  field :rss_url, type:String

  # authentication support
  field :login, type:String
  field :encrypted_password, type:String

  # location and organization details
  field :company, type:String
  belongs_to :org, :foreign_key => 'org_id'
  belongs_to :country

  # StackStudio
  embeds_many :cloud_credentials
  embeds_many :permissions

  # Stats for reporting
  field :last_login_at, type:Time
  field :num_logins, type:Integer, default:0

  # indexes
  index({login:1}, {unique:true})
  index "cloud_credentials._id" => 1

  # Validation Rules
  validates_presence_of :login
  validates_uniqueness_of :login, :case_sensitive => false
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_confirmation_of :password,  :if => :password
  validates_presence_of :country

  def self.find_by_login(login)
    return nil if login.nil? or login.empty?
    return Account.where(login:login).first || Account.where(email:login).first
  end

  # finds the account that contains the cloud credentials and returns it
  def self.find_cloud_credential(cloud_credential_id)
    return nil if cloud_credential_id.nil?
    account = Account.where({"cloud_credentials._id"=>Moped::BSON::ObjectId.from_string(cloud_credential_id.to_s)}).first
    (account.nil? ? nil : account.cloud_credential(cloud_credential_id))
  end

  # filters the embedded cloud accounts by ID
  def cloud_credential(cloud_credential_id)
    cred = self.cloud_credentials.select { |ca| ca.id.to_s == cloud_credential_id.to_s }.first
    #If openstack, merge the cloud_account's url to cloud_attributes hash
    if ! cred.cloud_account.url.nil?
      cred.cloud_attributes.merge!({"openstack_auth_url" => cred.cloud_account.url})
    end
    return cred
  end

  # sets the country for the account based on the country code (Representer support)
  def country_code=(code)
    self.country = Country.find_by_code(code)
  end

  # returns the country code for this account's country, or nil if not set (Representer support)
  def country_code
    (self.country.nil? ? nil : self.country.code)
  end

  def password=(pass)
    @password = pass
    # only set the encrypted password if we haven't set anything before, or if we are resetting the password
    if self.encrypted_password.nil? or (!self.encrypted_password.nil? and !pass.nil?)
      self.encrypted_password =  pass.nil? ? nil : ::BCrypt::Password.create(pass, { :cost => bcrypt_cost })
    end
  end

  def auth(pass, now=Time.now)
    if LDAP_ENABLED
      return ldap_auth(self.email, pass)
    end
    if BCrypt::Password.new(self.encrypted_password) == pass
      self.inc(:num_logins, 1)
      self.update_attribute(:last_login_at, now)
      true
    end
    return false
  end

  # return the default engine cost (the higher the longer it takes to encrypt). Tests may stub this to return 1, the lowest valid number
  def bcrypt_cost
    return BCrypt::Engine::DEFAULT_COST
  end

  # returns AccountSubscription instances with info about the organizations this account belongs to
  def subscriptions
    # subscriber entries are embedded in subscriptions inside of an
    # org. We'll flip this, so that we only return subscriber entries
    # for the account
    orgs = Org.all(:conditions=>{ "subscriptions.subscribers.account_id"=> self.id})
    subscribers = []
    orgs.each do |org|
      org.subscriptions.each do |subscription|
        subscribers += subscription.subscribers.select { |subscriber| subscriber.account_id.to_s == self.id.to_s }
      end
    end
    subscribers.flatten!
    subs = []
    subscribers.each do |subscriber|
      subscript = subscriber.subscription
      org = subscript.org
      subs << AccountSubscription.new(org.id.to_s, org.name, subscript.product, subscript.billing_level, subscriber.role)
    end
    subs
  end

  def subscriptions=(args); end; # empty impl to satisfy the representer
  
  def group_policies
      policies = []
      Group.each do |group|
          group.group_memberships.each do |membership|
              if membership.account_id == _id
                  policies.push(group.group_policy)
              end
          end
      end
      return policies
  end
  def group_policies=(args); end; # empty impl to satisfy the representer

  class AccountSubscription
    attr_accessor :org_id, :org_name, :product, :billing_level, :role

    def initialize(org_id=nil, org_name=nil, product=nil, billing_level=nil, role=nil)
      @org_id = org_id
      @org_name = org_name
      @product = product
      @billing_level = billing_level
      @role = role
    end
  end

  def add_cloud_credential!(cloud_account_id, cloud_credential)
    cloud_credential.cloud_account = CloudAccount.find(cloud_account_id)
    self.cloud_credentials << cloud_credential
    self.save!
  end

  def remove_cloud_credential!(cloud_credential_id)
    self.cloud_credentials.select { |c| c.id.to_s == cloud_credential_id.to_s }.each { |c| c.delete }
    self.save!
  end
  
  def add_permission!(permission)
	self.permissions << permission
	self.save!
  end
  
  def remove_permission!(permission_id)
	self.permissions.select { |p| p.id.to_s == permission_id.to_s }.each { |p| p.delete }
	self.save!
  end

  def add_key_pair!(cloud_credential_id, key_pair)
    cloud_credential = self.cloud_credentials.select{ |c| c.id.to_s == cloud_credential_id.to_s }.first
    if cloud_credential
      cloud_credential.key_pairs << key_pair
      self.save!
    end
  end

  def remove_key_pair!(cloud_credential_id, key_pair_id)
    cloud_credential = self.cloud_credentials.select{ |c| c.id.to_s == cloud_credential_id.to_s }.first
    if cloud_credential
      cloud_credential.key_pairs.select { |k| k.id.to_s == key_pair_id.to_s }.each { |k| k.delete }
      self.save!
    end
  end

  def add_audit_log!(cloud_credential_id, audit_log)
    cloud_credential = self.cloud_credentials.select{ |c| c.id.to_s == cloud_credential_id.to_s }.first
    if cloud_credential
      cloud_credential.audit_logs << audit_log
      self.save!
    end
  end

  def add_cloud_resource!(cloud_credential_id, cloud_resource)
    cloud_credential = self.cloud_credentials.select{ |c| c.id.to_s == cloud_credential_id.to_s }.first
    if cloud_credential
      cloud_credential.cloud_resources << cloud_resource
      self.save!
    end
  end
  
  # returns ProjectMember instances with info about the projects this account belongs to
  def project_memberships
    # member entries are embedded in projects. We'll consolidate this for the client
    projects = Project.all(:conditions=>{ "members.account_id"=> self.id })
	groups = Group.all(:conditions=>{ "group_memberships.account_id"=> self.id})
	projects_by_group = []
	groups.each do |g|
		Project.all(:conditions=>{"group_projects.group_id"=> g.id}).each { |p| projects_by_group << p}
	end
    memberships = []
    projects.each do |project|
      memberships += project.members.select { |member| member.account_id.to_s == self.id.to_s }
    end
	group_memberships = []
	# Find which GroupProject has the member, and build Hash with data to build ProjectMembership
	projects_by_group.each do |project|
		project.group_projects.each do |group_project|
			groups.each do |group|
				if group_project.group_id == group.id
					group_memberships << { :proj_id=>project.id, :proj_name=>project.name, :membership_id=>group_project.group_id, :permissions=>group_project.permissions, :role=>"group", :proj_status=>project.status}
				end
			end
		end
	end
    ships = []
    memberships.each do |membership|
      project = membership.project
      ships << ProjectMembership.new(project.id.to_s, project.name, membership.id.to_s, membership.permissions, membership.role, project.status, membership.last_opened_at)
    end
	group_memberships.each do |m|
	  already_membership = ships.select {|s| s.project_id == m[:proj_id].to_s}.first
	  if already_membership.nil?
		ships << ProjectMembership.new(m[:proj_id].to_s, m[:proj_name], m[:membership_id].to_s, m[:permissions], m[:role], m[:proj_status])
	  else
		already_membership.member_permissions |= m[:permissions]
	  end
	end
    ships
  end

  def project_memberships=(args); end; # empty impl to satisfy the representer

  class ProjectMembership
    attr_accessor :project_id, :project_name, :project_status, :member_id, :member_permissions, :role, :last_opened_at

    def initialize(project_id=nil, project_name=nil, member_id=nil, member_permissions=nil, role=nil, project_status=nil, last_opened_at=nil)
      @project_id = project_id
      @project_name = project_name
      @member_id = member_id
      @member_permissions = member_permissions
      @role = role
      @project_status = project_status
      @last_opened_at = last_opened_at
    end
  end

  def stats
    # For each user:
    # o   Total # of logins
    # o   Last sign in date
    # o   Total # of stacks
    # o   AWS Creds imported or not
    stats = { }
    stats[:login] = self.login
    stats[:email] = self.email
    stats[:first_name] = self.first_name
    stats[:last_name] = self.last_name
    stats[:total_logins] = self.num_logins
    stats[:last_login_at] = self.last_login_at
    stats[:total_projects_owned] = Project.count(:conditions=>{ "members.account_id"=> self.id, "role"=>Member::OWNER})
    stats[:total_projects_member] = Project.count(:conditions=>{ "members.account_id"=> self.id, "role"=>Member::MEMBER})
    stats[:total_cloud_credentials] = self.cloud_credentials.count
    return stats
  end
end
