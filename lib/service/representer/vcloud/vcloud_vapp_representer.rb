module VCloudVappRepresenter
  include Roar::Representer::JSON

  property :id
  property :name
  property :status
  property :deployed
  property :description

end