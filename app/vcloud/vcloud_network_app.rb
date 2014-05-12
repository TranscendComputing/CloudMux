require 'sinatra'
require 'fog'

class VCloudNetworkApp < VCloudApp
  get '/' do
    begin
      networks = @org.networks
      [OK, networks.to_json]
    rescue => error
      handle_error(error)
    end
  end

  get '/:id' do
    begin
      networks = @org.networks.get(params[:id])
      [OK, networks.to_json]
    rescue => error
      handle_error(error)
    end
  end
end
