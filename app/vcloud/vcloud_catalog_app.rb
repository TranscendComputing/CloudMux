require 'sinatra'
require 'fog'

class VCloudCatalogApp < VCloudApp
<<<<<<< HEAD
	
	get '/' do
		catalog_list = @org.catalogs.map do |catalog|
			catalog.extend(VCloudCatalogRepresenter)
			catalog.org = @org.name
			catalog.items = catalog.catalog_items.all.map { |item| {:name => item.name} }
			catalog
		end

		[OK, catalog_list.to_json]
	end

	get '/items' do
		catalog = @org.catalogs.get_by_name(params[:id])
		items = catalog.catalog_items.all

		items.each do |item|
			item.extend(VCloudCatalogItemRepresenter)
			item.catalog = catalog.name
		end

		[OK, items.to_json]
	end

	post '/instance' do
		catalog = @org.catalogs.get_by_name(params[:id])
		template = catalog.catalog_items.get_by_name(params[:template])

		vdc = @org.vdcs.first
		network = vdc.available_networks.first
		puts 'network: ' + network.to_json.to_s
		network_name = network[:name]

		network = @org.networks.get_by_name(network_name)

		puts 'network id: ' + network.id
		
		template.instantiate(params[:name], {
			:vdc_id => vdc.id,
			:network_id => network.id
		})

		[OK, { :success => true }]
	end
end
=======
  get '/' do
    catalogs = @org.catalogs.all
    [OK, catalogs.to_json]
  end
end
>>>>>>> 65909512813d792ee3c424ebea7d24b7876c8d71
