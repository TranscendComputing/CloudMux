require 'sinatra'
require 'fog'

class VCloudCatalogApp < VCloudApp
  #
  # Catalogs
  #
  get '/' do
    begin
      catalogs = @org.catalogs
      [OK, catalogs.to_json]
    rescue => error
      handle_error(error)
    end
  end

  get '/:id' do
    begin
      catalog = @org.catalogs.get(params[:id])
      [OK, catalog.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # Catalog Items
  #
  get '/:catalog_id/items' do
    begin
      catalog_items = @org.catalogs.get(params[:catalog_id]).catalog_items
      [OK, catalog_items.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # Create vApp
  #
  post '/:catalog_id/items/:id/vapp' do
    json_body = body_to_json_or_die('body' => request)
    begin
      template = @org.catalogs.get(params[:catalog_id]).catalog_items.get(params[:id])
      template.instantiate(json_body['vapp_name'], json_body['vapp_options'])
      [OK, { 'message' => 'vApp Creating.' }.to_json]
    rescue => error
      handle_error(error)
    end
  end
end
