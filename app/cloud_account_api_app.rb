require 'sinatra'

class CloudAccountApiApp < ApiBase
  get '/' do
    if params[:org_id].nil?
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Must provide org_id with request for cloud accounts."
      [BAD_REQUEST, message.to_json]
    elsif params[:account_id].nil?
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Must provide account_id with request for cloud accounts."
      [BAD_REQUEST, message.to_json]
    end

    per_page = (params[:per_page] || 20).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    conditions = { }
    conditions[:org_id] = params[:org_id]
    conditions[:cloud_id] = params[:cloud_id] if params[:cloud_id]
    cloud_accounts = CloudAccount.all.where(conditions)
    count = CloudAccount.where(conditions).count
    query = Query.new(count, page, offset, per_page)
    cloud_account_query = CloudAccountQuery.new(query, cloud_accounts).extend(CloudAccountQueryRepresenter)
    [OK, cloud_account_query.to_json]
  end

  get '/:id.json' do
    cloud_account = CloudAccount.find(params[:id])
    cloud_account.extend(CloudAccountRepresenter)
    cloud_account.to_json
  end

  post '/' do
    new_cloud_account = CloudAccount.new.extend(UpdateCloudAccountRepresenter)
    new_cloud_account.from_json(request.body.read)
    if new_cloud_account.valid?
      new_cloud_account.save!
      # refresh without the Update representer, so that we don't serialize private data back
      cloud_account = CloudAccount.find(new_cloud_account.id).extend(CloudAccountRepresenter)
      [CREATED, cloud_account.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_cloud_account.errors.full_messages.join(";")}"
      message.validation_errors = new_cloud_account.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_cloud_account.extend(UpdateCloudAccountRepresenter)
    update_cloud_account.from_json(request.body.read)
    if update_cloud_account.valid?
      update_cloud_account.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      cloud_account = CloudAccount.find(update_cloud_account.id).extend(CloudAccountRepresenter)
      [OK, cloud_account.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_cloud_account.errors.full_messages.join(";")}"
      message.validation_errors = update_cloud_account.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  delete '/:id' do
      cloud_account = CloudAccount.find(params[:id])
      cloud_account.delete
      [OK]
  end

  # Register a new service to an existing cloud_account
  post '/:id/services' do
    update_cloud_account = CloudAccount.find(params[:id])
    new_service = CloudService.new.extend(UpdateCloudServiceRepresenter)
    new_service.from_json(request.body.read)
    new_service.cloud_account = update_cloud_account
    new_service.save!
    cloud_account = CloudAccount.find(update_cloud_account.id).extend(CloudAccountRepresenter)
    update_cloud_account.extend(CloudAccountRepresenter)
    [OK, update_cloud_account.to_json]
  end

  # Update a service for an existing cloud_account
  put '/:id/services/:service_id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_service = update_cloud_account.find_service(params[:service_id])
    if update_service.nil?
      return [NOT_FOUND]
    end
    update_service.extend(UpdateCloudServiceRepresenter)
    update_service.from_json(request.body.read)
    if update_service.valid?
      update_service.save!
      updated_service = update_cloud_account.find_service(update_service.id)
      updated_service.extend(CloudServiceRepresenter)
      [OK, updated_service.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_service.errors.full_messages.join(";")}"
      message.validation_errors = update_service.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # Remove a service from an existing cloud_account
  delete '/:id/services/:service_id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_cloud_account.remove_service!(params[:service_id])
    cloud_account = CloudAccount.find(update_cloud_account.id).extend(CloudAccountRepresenter)
    update_cloud_account.extend(CloudAccountRepresenter)
    [OK, update_cloud_account.to_json]
  end

  # Register a new mapping to an existing cloud_account
  post '/:id/mappings' do
    update_cloud_account = CloudAccount.find(params[:id])
    new_mapping = CloudMapping.new.extend(UpdateCloudMappingRepresenter)
    new_mapping.properties = { }
    new_mapping.mapping_entries = []
    new_mapping.from_json(request.body.read)
    new_mapping.mappable = update_cloud_account
    new_mapping.save!
    update_cloud_account.extend(CloudAccountRepresenter)
    [OK, update_cloud_account.to_json]
  end

  # Update a mapping for an existing cloud_account
  put '/:id/mappings/:mapping_id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_mapping = update_cloud_account.find_mapping(params[:mapping_id])
    if update_mapping.nil?
      return [NOT_FOUND]
    end
    update_mapping.extend(UpdateCloudMappingRepresenter)
    update_mapping.from_json(request.body.read)
    if update_mapping.valid?
      update_mapping.save!
      updated_mapping = update_cloud_account.find_mapping(update_mapping.id)
      updated_mapping.extend(CloudMappingRepresenter)
      [OK, updated_mapping.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_mapping.errors.full_messages.join(";")}"
      message.validation_errors = update_mapping.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end  

  # Remove a mapping from an existing cloud_account
  delete '/:id/mappings/:mapping_id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_cloud_account.remove_mapping!(params[:mapping_id])
    update_cloud_account.extend(CloudAccountRepresenter)
    [OK, update_cloud_account.to_json]
  end
  
  # Register a new compute price to an existing cloud_account
  post '/:id/prices' do
    update_cloud_account = CloudAccount.find(params[:id])
    new_price = Price.new.extend(UpdatePriceRepresenter)
    new_price.properties = { }
    new_price.entries = []
    new_price.from_json(request.body.read)
    new_price.cloud_account = update_cloud_account
    new_price.save!
    update_cloud_account.extend(CloudAccountRepresenter)
    [OK, update_cloud_account.to_json]
  end
  
  # Remove a price from an existing cloud_account
  delete '/:id/prices/:price_id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_cloud_account.remove_price!(params[:price_id])
    cloud_account = CloudAccount.find(update_cloud_account.id).extend(CloudAccountRepresenter)
    update_cloud_account.extend(CloudAccountRepresenter)
    [OK, update_cloud_account.to_json]
  end
  
  # Update a price effective price and date, and add to entries
  put '/:id/prices/:price_id' do
    update_cloud_account = CloudAccount.find(params[:id])
    update_price = update_cloud_account.find_price(params[:price_id])
    if update_price.nil?
      return [NOT_FOUND]
    end
    update_price.extend(UpdatePriceRepresenter)
    update_price.from_json(request.body.read)
    if update_price.valid?
      update_price.save!
      updated_price = update_cloud_account.find_price(update_price.id)
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
