module VCloudCatalogRepresenter
  include Roar::Representer::JSON

  property :id
  property :name
  property :items

  attr_accessor :items
end