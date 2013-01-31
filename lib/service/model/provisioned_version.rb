#
# Tracks one or more provisioned projects for a specific version and
# environment. They are named to differentiate between multiple
# provisionings for the same environment
#
class ProvisionedVersion
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :project
  embeds_many :provisioned_instances

  field :stack_name, type:String
  field :environment, type:String
  field :version, type:String

  index([ [ :project_id, Mongo::ASCENDING ],  [ :version, Mongo::ASCENDING ],  [ :environment, Mongo::ASCENDING ] ])

  validates_presence_of :stack_name
  validates_presence_of :environment
  validates_presence_of :version

  def self.find_for_project(project_id, version, env)
    self.find(:first, :conditions=>{ :project_id=>project_id, :version=>version, :environment=>env })
  end

  def find_instance(instance_id)
    self.provisioned_instances.select { |i| i.instance_id == instance_id or i.id.to_s == instance_id}.first
  end
end
