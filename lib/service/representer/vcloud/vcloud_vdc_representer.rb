module VCloudVdcRepresenter
  include Roar::Representer::JSON

  property :name
  property :org

  attr_accessor :org
end