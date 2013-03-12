require 'sinatra'

class CloudAccountApiApp < ApiBase
  get '/:id.json' do
    cloud_account = CloudAccount.find(params[:id])
    cloud_account.extend(CloudAccountRepresenter)
    cloud_account.to_json
  end

  post '/' do
    new_cloud_accout = CloudAccount.new.extend(UpdateCloudAccountRepresenter)
    new_cloud_accout.from_json(request.body.read)
    if new_cloud_accout.valid?
      new_cloud_accout.save!
      # refresh without the Update representer, so that we don't serialize private data back
      cloud_accout = CloudAccount.find(new_cloud_accout.id).extend(CloudAccountRepresenter)
      [CREATED, cloud_accout.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_cloud_accout.errors.full_messages.join(";")}"
      message.validation_errors = new_cloud_accout.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_cloud_accout = CloudAccount.find(params[:id])
    update_cloud_accout.extend(UpdateCloudAccountRepresenter)
    update_cloud_accout.from_json(request.body.read)
    if update_cloud_accout.valid?
      update_cloud_accout.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      cloud_accout = CloudAccount.find(update_cloud_accout.id).extend(CloudAccountRepresenter)
      [OK, cloud_accout.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_cloud_accout.errors.full_messages.join(";")}"
      message.validation_errors = update_cloud_accout.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  delete '/:id' do
      cloud_accout = CloudAccount.find(params[:id])
      cloud_accout.delete
      [OK]
  end

  # Register a new service to an existing cloud_accout
  post '/:id/services' do
    update_cloud_accout = CloudAccount.find(params[:id])
    new_service = CloudService.new.extend(UpdateCloudServiceRepresenter)
    new_service.from_json(request.body.read)
    new_service.cloud_accout = update_cloud_accout
    new_service.save!
    cloud_accout = CloudAccount.find(update_cloud_accout.id).extend(CloudAccountRepresenter)
    update_cloud_accout.extend(CloudAccountRepresenter)
    [OK, update_cloud_accout.to_json]
  end

  # Remove a service from an existing cloud_accout
  delete '/:id/services/:service_id' do
    update_cloud_accout = CloudAccount.find(params[:id])
    update_cloud_accout.remove_service!(params[:service_id])
    cloud_accout = CloudAccount.find(update_cloud_accout.id).extend(CloudAccountRepresenter)
    update_cloud_accout.extend(CloudAccountRepresenter)
    [OK, update_cloud_accout.to_json]
  end

  # Register a new mapping to an existing cloud_accout
  post '/:id/mappings' do
    update_cloud_accout = CloudAccount.find(params[:id])
    new_mapping = CloudMapping.new.extend(UpdateCloudMappingRepresenter)
    new_mapping.properties = { }
    new_mapping.mapping_entries = []
    new_mapping.from_json(request.body.read)
    new_mapping.mappable = update_cloud_accout
    new_mapping.save!
    update_cloud_accout.extend(CloudAccountRepresenter)
    [OK, update_cloud_accout.to_json]
  end

  # Remove a mapping from an existing cloud_accout
  delete '/:id/mappings/:mapping_id' do
    update_cloud_accout = CloudAccount.find(params[:id])
    update_cloud_accout.remove_mapping!(params[:mapping_id])
    update_cloud_accout.extend(CloudAccountRepresenter)
    [OK, update_cloud_accout.to_json]
  end
  
  # Register a new compute price to an existing cloud_accout
  post '/:id/prices' do
    update_cloud_accout = CloudAccount.find(params[:id])
    new_price = Price.new.extend(UpdatePriceRepresenter)
    new_price.properties = { }
    new_price.entries = []
    new_price.from_json(request.body.read)
    new_price.cloud_accout = update_cloud_accout
    new_price.save!
    update_cloud_accout.extend(CloudAccountRepresenter)
    [OK, update_cloud_accout.to_json]
  end
  
  # Remove a price from an existing cloud_accout
  delete '/:id/prices/:price_id' do
    update_cloud_accout = CloudAccount.find(params[:id])
    update_cloud_accout.remove_price!(params[:price_id])
    cloud_accout = CloudAccount.find(update_cloud_accout.id).extend(CloudAccountRepresenter)
    update_cloud_accout.extend(CloudAccountRepresenter)
    [OK, update_cloud_accout.to_json]
  end
  
  # Update a price effective price and date, and add to entries
  put '/:id/prices/:price_id' do
    update_cloud_accout = CloudAccount.find(params[:id])
    update_price = update_cloud_accout.find_price(params[:price_id])
    if update_price.nil?
      return [NOT_FOUND]
    end
    update_price.extend(UpdatePriceRepresenter)
    update_price.from_json(request.body.read)
    if update_price.valid?
      update_price.save!
      updated_price = update_cloud_accout.find_price(update_price.id)
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
