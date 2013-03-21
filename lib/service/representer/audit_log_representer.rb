module AuditLogRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :logical_resource_id
  property :physical_resource_id
  property :service_type
  property :action
  hash :parameters
  property :response_status_code
  hash :errors
  property :date
end
