require 'sinatra'
require 'fog'

class VCloudNetworkApp < VCloudApp
  ##~ sapi = source2swagger.namespace("vcloud_network")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/network"
  ##~ a.description = "List Networks"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_networks"
  ##~ op.summary = "List networks in an organization"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/' do
    networks = @org.networks
    [OK, networks.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/network/:id"
  ##~ a.description = "Get network by id"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_network_by_id"
  ##~ op.summary = "Get network by id"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/:id' do
    networks = @org.networks.get(params[:id])
    [OK, networks.to_json]
  end
end
