module CloudCredentialRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :cloud_account_id
  property :cloud_name
  property :cloud_provider
  property :name
  property :description
  property :access_key
  property :secret_key
  property :cloud_attributes
  property :stack_preferences
  property :topstack_id
  property :topstack_enabled
  property :topstack_configured
  collection :audit_logs, :class=>AuditLog, :extend => AuditLogRepresenter
  collection :cloud_resources, :class=>CloudResource, :extend => CloudResourceRepresenter
end
