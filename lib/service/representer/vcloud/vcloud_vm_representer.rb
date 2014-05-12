module VCloudVmRepresenter
  include Roar::Representer::JSON

  property :name
  property :status
  property :cpu
  property :memory
end