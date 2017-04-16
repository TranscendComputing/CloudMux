require 'sinatra'
require 'fog'

class VCloudCatalogApp < VCloudApp
  ##~ sapi = source2swagger.namespace("vcloud_catalog")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/catalogs"
  ##~ a.description = "Manage vCloud Catalogs"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_catalogs"
  ##~ op.summary = "List all catalogs in organization"  
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/' do
    catalogs = @org.catalogs.all(false)
    catalog_list = catalogs.map do |catalog|
      catalog.extend(VCloudCatalogRepresenter)
      catalog.items = catalog.catalog_items.all(false).map do |item|
        {:id => item.id, :name => item.name, :descripton => item.description}
      end
      catalog
    end
    [OK, catalog_list.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/catalogs/:id"
  ##~ a.description = "Get catalog by id"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_catalog"
  ##~ op.summary = "Get catalog by id"  
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/:id' do
    catalog = @org.catalogs.get(params[:id])
    catalog.extend(VCloudCatalogRepresenter)
    catalog.items = catalog.catalog_items.all(false)
    [OK, catalog.to_json]
  end

  #
  # Catalog Items
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/catalogs/:id/items"
  ##~ a.description = "Get items in catalog"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_catalog_items"
  ##~ op.summary = "Get items in catalog"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/:catalog_id/items' do
    catalog_items = @org.catalogs.get(params[:catalog_id]).catalog_items
    [OK, catalog_items.to_json]
  end

  #
  # Create vApp
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/catalogs/:catalog_id/items/:id/vapp"
  ##~ a.description = "Get catalog by id"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "instantiate_vapp"
  ##~ op.summary = "Instatiate vApp from template"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/:catalog_id/items/:id/vapp' do
    template = @org.catalogs.get(params[:catalog_id]).catalog_items.get(params[:id])
    if params[:vapp_options].nil?
      template.instantiate(params['vapp_name'])
    else
      template.instantiate(params['vapp_name'], params['vapp_options'])
    end
      
    [OK, { 'message' => 'vApp Creating.' }.to_json]
  end
end
