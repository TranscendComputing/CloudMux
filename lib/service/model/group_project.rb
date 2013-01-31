class GroupProject
  # Mongoid Mappings
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :project
  belongs_to :group, :foreign_key => 'group_id'

  # Permission support
  embeds_many :permissions
  
  validates_presence_of :group
end
