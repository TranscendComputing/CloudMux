require 'sinatra'

class OrgApiApp < ApiBase

  # Create a new org
  post '/' do
    new_org = Org.new.extend(UpdateOrgRepresenter)
    new_org.from_json(request.body.read)
    if new_org.valid?
      new_org.save!
  	  Group.create!(:name => "Development", :description => "default development group", :org => new_org)
  	  Group.create!(:name => "Test", :description => "default test group", :org => new_org)
  	  Group.create!(:name => "Stage", :description => "default stage group", :org => new_org)
  	  Group.create!(:name => "Production", :description => "default production group", :org => new_org)
      org = Org.find(new_org.id).extend(OrgRepresenter)
      [CREATED, org.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_org.errors.full_messages.join(";")}"
      message.validation_errors = new_org.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # Update an existing org's details. Does not update the subscription level - separate API
  put '/:id' do
    update_org = Org.find(params[:id])
    update_org.extend(UpdateOrgRepresenter)
    update_org.from_json(request.body.read)
    if update_org.valid?
      update_org.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      org = Org.find(update_org.id).extend(OrgRepresenter)
      [OK, org.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_org.errors.full_messages.join(";")}"
      message.validation_errors = update_org.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # update the subscription details for a product
  put '/:id/:product/subscription' do
    update_org = Org.find(params[:id])
    subscription = update_org.product_subscription(params[:product])
    if subscription.nil?
      # create one
      subscription = Subscription.new(:product=>params[:product])
      update_org.subscriptions << subscription
    end

    subscription.extend(UpdateSubscriptionRepresenter)
    subscription.from_json(request.body.read)
    if subscription.valid?
      subscription.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      org = Org.find(update_org.id).extend(OrgRepresenter)
      [OK, org.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_org.errors.full_messages.join(";")}"
      message.validation_errors = update_org.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # Add a subscriber to an existing org's product subscription
  post '/:id/:product/subscribers' do
    update_org = Org.find(params[:id])
    subscription = update_org.product_subscription(params[:product])
    if subscription.nil?
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Product not found: #{params[:product]}"
      message.validation_errors = update_org.errors.to_hash
      return [BAD_REQUEST, message.to_json]
    end

    struct = Struct.new(:account_id, :role).new
    struct.extend(AddSubscriberRepresenter)
    struct.from_json(request.body.read)
    account = Account.find(struct.account_id)
    update_org.add_subscriber!(subscription.product, account, struct.role)
    [OK]
  end

  # Remove a subscriber to an existing org's product subscription
  delete '/:id/:product/subscribers/:subscriber_account_id' do
    update_org = Org.find(params[:id])
    subscription = update_org.product_subscription(params[:product])
    if subscription.nil?
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Product not found: #{params[:product]}"
      message.validation_errors = update_org.errors.to_hash
      return [BAD_REQUEST, message.to_json]
    end

    account = Account.find(params[:subscriber_account_id])
    update_org.remove_subscriber!(params[:product], account)
    [OK]
  end

  # Fetch an org's details
  get '/:id.json' do
    org = Org.find(params[:id])
    org.extend(OrgRepresenter)
    [OK, org.to_json]
  end
  
  # Register a new group to an existing org
  post '/:id/groups' do
    update_org = Org.find(params[:id])
    new_group = Group.new.extend(UpdateGroupRepresenter)
    new_group.from_json(request.body.read)
	new_group.org = update_org
    new_group.save!
    update_org.extend(OrgRepresenter)
    [OK, update_org.to_json]
  end
  
  # Remove a group from an existing org
  delete '/:id/groups/:group_id' do
    update_org = Org.find(params[:id])
    update_org.remove_group!(params[:group_id])
    update_org.extend(OrgRepresenter)
    [OK, update_org.to_json]
  end
  
  # Register an account to an existing group
  post '/:id/groups/:group_id/accounts/:account_id' do
	update_org = Org.find(params[:id])
	account = Account.find(params[:account_id])
	if update_org.id.to_s == account.org_id.to_s
		update_org.add_account_to_group!(params[:group_id], params[:account_id])
		update_org.extend(OrgRepresenter)
		[OK, update_org.to_json]
	else
		message = Error.new.extend(ErrorRepresenter)
		message.message = "Account not found in org."
		message.validation_errors = update_org.error.to_hash
		return [BAD_REQUEST, message.to_json]
	end
  end
  
  # Remove an account from an existing group
  delete '/:id/groups/:group_id/accounts/:account_id' do
	update_org = Org.find(params[:id])
	update_org.remove_account_from_group!(params[:group_id], params[:account_id])
	update_org.extend(OrgRepresenter)
	[OK, update_org.to_json]
  end

  # Register a new mapping to an existing org
  post '/:id/mappings' do
    update_org = Org.find(params[:id])
    new_mapping = CloudMapping.new.extend(UpdateCloudMappingRepresenter)
    new_mapping.properties = { }
    new_mapping.mapping_entries = []
    new_mapping.from_json(request.body.read)
    new_mapping.mappable = update_org
    new_mapping.save!
    update_org.extend(OrgRepresenter)
    [OK, update_org.to_json]
  end
  
  # Update an existing mapping for an org
  put '/:id/mappings/:mapping_id' do
    update_org = Org.find(params[:id])
    update_mapping = update_org.find_mapping(params[:mapping_id])
    if update_mapping.nil?
      return [NOT_FOUND]
    end
    update_mapping.extend(UpdateCloudMappingRepresenter)
    update_mapping.from_json(request.body.read)
    if update_mapping.valid?
      update_mapping.save!
      updated_org = Org.find(params[:id])
      updated_org.extend(OrgRepresenter)
      [OK, updated_org.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_mapping.errors.full_messages.join(";")}"
      message.validation_errors = update_mapping.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end  
  end

  # Remove a mapping from an existing org
  delete '/:id/mappings/:mapping_id' do
    update_org = Org.find(params[:id])
    update_org.remove_mapping!(params[:mapping_id])
    update_org.extend(OrgRepresenter)
    [OK, update_org.to_json]
  end
end
