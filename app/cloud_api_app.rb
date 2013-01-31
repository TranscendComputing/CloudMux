require 'sinatra'

class CloudApiApp < ApiBase
  get '/' do
    per_page = (params[:per_page] || 1000).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    clouds = Cloud.all
    count = Cloud.count
    query = Query.new(count, page, offset, per_page)
    cloud_query = CloudQuery.new(query, clouds).extend(CloudQueryRepresenter)
    [OK, cloud_query.to_json]
  end

  get '/:id.json' do
    cloud = Cloud.find_by_permalink(params[:id]) || Cloud.find(params[:id])
    cloud.extend(CloudRepresenter)
    cloud.to_json
  end

  post '/' do
    new_cloud = Cloud.new.extend(UpdateCloudRepresenter)
    new_cloud.from_json(request.body.read)
    if new_cloud.valid?
      new_cloud.save!
      # refresh without the Update representer, so that we don't serialize private data back
      cloud = Cloud.find(new_cloud.id).extend(CloudRepresenter)
      [CREATED, cloud.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_cloud.errors.full_messages.join(";")}"
      message.validation_errors = new_cloud.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_cloud = Cloud.find(params[:id])
    update_cloud.extend(UpdateCloudRepresenter)
    update_cloud.from_json(request.body.read)
    if update_cloud.valid?
      update_cloud.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      cloud = Cloud.find(update_cloud.id).extend(CloudRepresenter)
      [OK, cloud.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_cloud.errors.full_messages.join(";")}"
      message.validation_errors = update_cloud.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  delete '/:id' do
	  cloud = Cloud.find(params[:id])
	  cloud.delete
	  [OK]
  end

  # Register a new service to an existing cloud
  post '/:id/services' do
    update_cloud = Cloud.find(params[:id])
    new_service = CloudService.new.extend(UpdateCloudServiceRepresenter)
    new_service.from_json(request.body.read)
    new_service.cloud = update_cloud
    new_service.save!
    cloud = Cloud.find(update_cloud.id).extend(CloudRepresenter)
    update_cloud.extend(CloudRepresenter)
    [OK, update_cloud.to_json]
  end

  # Remove a service from an existing cloud
  delete '/:id/services/:service_id' do
    update_cloud = Cloud.find(params[:id])
    update_cloud.remove_service!(params[:service_id])
    cloud = Cloud.find(update_cloud.id).extend(CloudRepresenter)
    update_cloud.extend(CloudRepresenter)
    [OK, update_cloud.to_json]
  end

  # Register a new mapping to an existing cloud
  post '/:id/mappings' do
    update_cloud = Cloud.find(params[:id])
    new_mapping = CloudMapping.new.extend(UpdateCloudMappingRepresenter)
    new_mapping.properties = { }
    new_mapping.mapping_entries = []
    new_mapping.from_json(request.body.read)
    new_mapping.mappable = update_cloud
    new_mapping.save!
    update_cloud.extend(CloudRepresenter)
    [OK, update_cloud.to_json]
  end

  # Remove a mapping from an existing cloud
  delete '/:id/mappings/:mapping_id' do
    update_cloud = Cloud.find(params[:id])
    update_cloud.remove_mapping!(params[:mapping_id])
    update_cloud.extend(CloudRepresenter)
    [OK, update_cloud.to_json]
  end
  
  # Register a new compute price to an existing cloud
  post '/:id/prices' do
    update_cloud = Cloud.find(params[:id])
    new_price = Price.new.extend(UpdatePriceRepresenter)
    new_price.properties = { }
    new_price.entries = []
    new_price.from_json(request.body.read)
	new_price.cloud = update_cloud
    new_price.save!
    update_cloud.extend(CloudRepresenter)
    [OK, update_cloud.to_json]
  end
  
  # Remove a price from an existing cloud
  delete '/:id/prices/:price_id' do
    update_cloud = Cloud.find(params[:id])
    update_cloud.remove_price!(params[:price_id])
    cloud = Cloud.find(update_cloud.id).extend(CloudRepresenter)
    update_cloud.extend(CloudRepresenter)
    [OK, update_cloud.to_json]
  end
  
  # Update a price effective price and date, and add to entries
  put '/:id/prices/:price_id' do
	update_cloud = Cloud.find(params[:id])
    update_price = update_cloud.find_price(params[:price_id])
    if update_price.nil?
      return [NOT_FOUND]
    end
    update_price.extend(UpdatePriceRepresenter)
    update_price.from_json(request.body.read)
    if update_price.valid?
      update_price.save!
      updated_price = update_cloud.find_price(update_price.id)
      updated_price.extend(PriceRepresenter)
      [OK, updated_price.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_price.errors.full_messages.join(";")}"
      message.validation_errors = update_price.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end
end
