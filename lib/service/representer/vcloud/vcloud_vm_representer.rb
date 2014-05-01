module VCloudVmRepresenter
  include Roar::Representer::JSON

  property :name
  property :status
  property :cpu
  property :memory

  property :org
  property :vdc
  property :vapp

  attr_accessor :org
  attr_accessor :vdc
  attr_accessor :vapp
end