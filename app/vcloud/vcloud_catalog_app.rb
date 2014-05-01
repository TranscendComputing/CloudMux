require 'sinatra'
require 'fog'

class VCloudCatalogApp < VCloudApp
	get '/' do 
		catalogs = @org.catalogs
		[OK, catalogs.to_json]
	end
end