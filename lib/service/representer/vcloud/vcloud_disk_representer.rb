module VCloudDiskRepresenter
  include Roar::Representer::JSON

  property :name
  property :id
  property :capacity
  property :description
end