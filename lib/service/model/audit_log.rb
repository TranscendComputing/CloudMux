#
# Captures api actions for a user's cloud account
#
class AuditLog
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :cloud_account

  field :logical_resource_id, type:String
  field :physical_resource_id, type:String
  field :service_type, type:String
  field :action, type:String
  field :parameters, type:Hash
  field :response_status_code, type:Integer
  field :errors, type:Hash
  field :date, type:String
end
