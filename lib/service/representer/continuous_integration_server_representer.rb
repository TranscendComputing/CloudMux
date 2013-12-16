module ContinuousIntegrationServerRepresenter
  include Roar::Representer::JSON

  property :name
  property :type
  property :host
  property :protocol
  property :port
  property :username
  property :password
end