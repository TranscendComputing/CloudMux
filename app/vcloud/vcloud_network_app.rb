require 'sinatra'
require 'fog'

class VCloudNetworkApp < VCloudApp
  get '/' do
    networks = @org.networks.all
    [OK, networks.to_json]
  end
end
