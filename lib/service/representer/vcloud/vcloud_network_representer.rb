module VCloudNetworkRepresenter
  include Roar::Representer::JSON

  property :name
  property :info
  property :network
  property :is_connected
  property :mac_address
  property :ip_address_allocation_mode
end