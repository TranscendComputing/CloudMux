module ConfigManagerRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  #self.representation_wrap = true

  property :name
  property :protocol
  property :host
  property :port
  property :type
  property :path
  property :enabled
  property :auth_properties
  property :source_control_credential, :class=>SourceControlCredential, :extend => SourceControlCredentialRepresenter
end