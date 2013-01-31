class Permission
  VIEW = 'view_source'
  EDIT = 'edit_source'
  PUBLISH = 'public_source'
  PROMOTE = 'promote_environment'
  CREATE_STACK = 'create_stack'
  UPDATE_STACK = 'update_stack'
  DELETE_STACK = 'delete_stack'
  MONITOR = 'monitor'
  
  include Mongoid::Document
  
  embedded_in :account
  embedded_in :group_project
  embedded_in :member
  
  field :name, type:String
  field :environment, type:String

  validates_presence_of :name
  validates_presence_of :environment
end