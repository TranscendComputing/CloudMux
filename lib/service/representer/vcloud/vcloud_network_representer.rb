module VCloudNetworkRepresenter
  include Roar::Representer::JSON
  property :name
  property :is_connected
  property :mac_address
  property :ip_address_allocation_mode
end