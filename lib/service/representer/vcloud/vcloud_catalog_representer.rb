module VCloudCatalogRepresenter
  include Roar::Representer::JSON

  property :name
  property :org
  property :items

  attr_accessor :org
  attr_accessor :items
end