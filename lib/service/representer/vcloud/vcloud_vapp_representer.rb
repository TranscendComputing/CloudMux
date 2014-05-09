module VCloudVappRepresenter
  include Roar::Representer::JSON

  property :name
  property :org
  property :vdc
  property :status
  property :deployed
  property :description

  attr_accessor :org
  attr_accessor :vdc
end