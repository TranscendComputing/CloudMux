module VCloudCatalogRepresenter
  include Roar::Representer::JSON

  property :name
  property :org
  property :vdc
  property :vapp
  property :vm

  collection :catalog_items
end