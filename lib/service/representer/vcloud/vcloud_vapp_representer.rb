module VCloudVappRepresenter
  include Roar::Representer::JSON

  property :name
  property :org
  property :vdc

  attr_accessor :org
  attr_accessor :vdc
end