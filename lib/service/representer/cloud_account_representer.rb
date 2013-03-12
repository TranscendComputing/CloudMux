module CloudAccountRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :name
  property :cloud_id
  property :org_id
  property :cloud_name
  property :cloud_provider
  property :url
  property :protocol
  property :host
  property :port
  property :public
  property :topstack_enabled
  property :topstack_id
  collection :prices, :class=>Price, :extend => PriceRepresenter
  collection :cloud_services, :class=>CloudService, :extend => CloudServiceRepresenter
  collection :cloud_mappings, :class=>CloudMapping, :extend => CloudMappingRepresenter
end
