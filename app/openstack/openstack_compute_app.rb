require 'sinatra'
require 'fog'

class OpenstackComputeApp < ResourceApiBase

  before do
    params["provider"] = "openstack"
    @service_long_name = "Compute Service"
    @service_class = Fog::Compute
    @compute = can_access_service(params)
  end
  
  ##~ sapi = source2swagger.namespace("openstack_compute")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe current instances (OpenStack cloud)"  
  ##~ op.nickname = "describe_instances"
  ##~ op.parameters.add :name => "filters", :description => "Filters for instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of instances returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/instances' do
    filters = params[:filters]

    if filters.nil?
      response = @compute.servers
    else
      response = @compute.servers.all(filters)
    end

    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Run a new instance (OpenStack cloud)"  
  ##~ op.nickname = "run_instance"
  ##~ op.errorResponses.add :reason => "Success, new instance returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/instances' do
    json_body = body_to_json_or_die("body" => request)

    #Check the user has access to the image being requested.
    can_create_instance(
      "cred_id" => params[:cred_id],
      "action"  => "use_image",
      "options" => {:image_id => json_body["instance"]["image_ref"]}
    )

    #Check the user hasn't exceded the limit for instances set in policy.
    can_create_instance(
      "cred_id" => params[:cred_id],
      "action"  => "create_instance",
      "options" => {
        :resources => @compute.servers,
        :uid => @compute.current_user['id']
      }
    )

    response = @compute.servers.create(json_body["instance"])
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/disassociate_address"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Disassociate address from instance (OpenStack cloud)"  
  ##~ op.nickname = "disassociate_address_instance"
  ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, address associated with instance", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/instances/:id/disassociate_address' do
    json_body = body_to_json_or_die("body" => request, "args" => ["ip_address"])
    response = @compute.disassociate_address(params[:id], json_body["ip_address"])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/unpause"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Unpause instance (OpenStack cloud)"  
  ##~ op.nickname = "unpause_instance"
  ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, instance unpaused", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/instances/:id/unpause' do
    reponse = @compute.unpause_server(params[:id])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/pause"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Pause instance (OpenStack cloud)"  
  ##~ op.nickname = "pause_instance"
  ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, instance paused", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/instances/:id/pause' do
    response = @compute.pause_server(params[:id])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/reboot"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Reboot instance (OpenStack cloud)"  
  ##~ op.nickname = "reboot_instance"
  ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, instance rebooted", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/instances/:id/reboot' do
    response = @compute.reboot_server(params[:id])
    [OK, response.to_json]
  end

  get '/instances/:id/security_groups' do
    groups = @compute.servers.get(params[:id]).security_groups
    response = groups.collect{|group| group.attributes}
    [OK, response.to_json]
  end

  post '/instances/:id/change_groups' do
    body = body_to_json(request)

    body["add"].each do |name| 
      @compute.add_security_group(params[:id], name)
    end

    body["remove"].each do |name| 
      @compute.remove_security_group(params[:id], name)
    end

    [OK, {:message=>"Security groups successfully changed"}.to_json]
  end

  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete instance (OpenStack cloud)"  
  ##~ op.nickname = "delete_instance"
  ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, instance deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/instances/:id' do
    response = @compute.servers.get(params[:id]).destroy
    [OK, response.to_json]
  end

  #
  # Compute IP Pools
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/address_pools"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describes address pools (OpenStack cloud)"  
  ##~ op.nickname = "describe_address_pools"
  ##~ op.errorResponses.add :reason => "Success, list of address pools returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/address_pools' do
    response = @compute.list_address_pools.body["floating_ip_pools"]
    [OK, response.to_json]
  end
  
  #
  # Compute Host
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/hosts/describe"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe hosts (OpenStack cloud)"  
  ##~ op.nickname = "describe_hosts"
  ##~ op.errorResponses.add :reason => "Success, list of hosts returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/hosts/describe' do
    response = @compute.list_hosts.body["hosts"].find_all {|h| h["service"] == "@compute"}
    [OK, response.to_json]
  end

  #
  # Compute Images
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/images"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe images (OpenStack cloud)"  
  ##~ op.nickname = "describe_images"
  ##~ op.errorResponses.add :reason => "Success, list of images returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/images' do
    filters = params[:filters]

    if filters.nil?
      response = @compute.images
    else
      response = @compute.images.all(filters)
    end

    [OK, response.to_json]
  end

  #
  # Compute Flavors
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/flavors/describe"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe flavors (OpenStack cloud)"  
  ##~ op.nickname = "describe_flavors"
  ##~ op.errorResponses.add :reason => "Success, list of flavors returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/flavors/describe' do
    response = @compute.flavors
    [OK, response.to_json]
  end
  
  #
  # Compute Security Group
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/security_groups"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe security groups (OpenStack cloud)"  
  ##~ op.nickname = "describe_security_groups"
  ##~ op.parameters.add :name => "filters", :description => "Filters for security groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of security groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/security_groups' do
    filters = params[:filters]

    if filters.nil?
      response = @compute.security_groups
    else
      response = @compute.security_groups.all(filters)
    end

    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/security_groups"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "PUT"
  ##~ op.summary = "Creates new security group (OpenStack cloud)"  
  ##~ op.nickname = "create_security_group"
  ##~ op.errorResponses.add :reason => "Success, new security group created", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  put '/security_groups' do
    json_body = body_to_json_or_die("body" => request)
    user_id = Auth.find_account(params[:cred_id]).id

    #Check if the user hasn't exceeded the limit set by policy.
    can_create_instance(
      "cred_id" => params[:cred_id],
      "action"  => "create_security_group",
      "options" => {
        :instance_count => UserResource.count_resources(user_id,"Security Group")
      }
    )

    response = @compute.security_groups.create(json_body["security_group"])

    UserResource.create!(
      account_id: user_id,
      resource_id: response.id,
      resource_type: "Security Group",
      operation: "create"
    )

    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/security_groups"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete security group (OpenStack cloud)"  
  ##~ op.nickname = "delete_security_group"
  ##~ op.errorResponses.add :reason => "Success, security group deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/security_groups' do
    json_body = body_to_json_or_die("body" => request, "args" => ["security_group"])
    response = @compute.security_groups.get(json_body["security_group"]["id"]).destroy
    UserResource.delete_resource(json_body["security_group"]["id"])
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/security_groups/delete_rule"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete security groups rule (OpenStack cloud)"  
  ##~ op.nickname = "delete_rule_security_groups"
  ##~ op.errorResponses.add :reason => "Success, security groups rule deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/security_groups/delete_rule' do
    json_body = body_to_json_or_die("body" => request, "args" => ["rule_id"])
    group = @compute.security_groups.get(json_body["group_id"])
    group.delete_security_group_rule(json_body["rule_id"])
    [OK, @compute.security_groups.get(json_body["group_id"]).to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/security_groups/:id/add_rule"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "PUT"
  ##~ op.summary = "Add security groups rule (OpenStack cloud)"  
  ##~ op.nickname = "add_rule_security_groups"
  ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, security groups rule added", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  put '/security_groups/:id/add_rule' do
    json_body = body_to_json_or_die("body" => request, "args" => ["rule"])
    group = @compute.security_groups.get(params[:id])

    can_create_instance(
      "cred_id" => params[:cred_id],
      "action"  => "create_security_group_rule",
      "options" => {:instance_count => group.rules.count}
    )

    rule = json_body["rule"]
    rule = group.create_security_group_rule(
      rule["fromPort"],
      rule["toPort"],
      rule["ipProtocol"],
      rule["cidr"],
      rule["groupId"]
    )

    [OK, @compute.security_groups.get(params[:id]).to_json]
  end
  
  
  #
  # Compute Key Pairs
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/key_pairs"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe key pairs (OpenStack cloud)"  
  ##~ op.nickname = "describe_key_pairs"
  ##~ op.errorResponses.add :reason => "Success, list of key pairs returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/key_pairs' do
    response = @compute.key_pairs
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/key_pairs"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Names key pair (OpenStack cloud)"  
  ##~ op.nickname = "name_key_pair"
  ##~ op.parameters.add :name => "name", :description => "Name for key pair", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, key pair named", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/key_pairs' do
    halt [BAD_REQUEST] if params[:name].nil?
    response = @compute.key_pairs.create({"name"=>params[:name]})
    headers["Content-disposition"] = "attachment; filename=" + response.name + ".pem"
    [OK, response.private_key]
  end

  post '/key_pairs/import' do
    json_body = body_to_json_or_die(
      "body" => request,
      "args" => ["key_pair"]
    )["key_pair"]

    if json_body["name"].nil?
      [BAD_REQUEST, {:message=>"Must provide parameter name"}.to_json]
    elsif json_body["public_key"].nil?
      [BAD_REQUEST, {:message=>"Must provide parameter public_key"}.to_json]
    else
      response = @compute.create_key_pair(json_body["name"], json_body["public_key"])
      [OK, {:message =>"Successfully imported keypair."}.to_json]
    end
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/key_pairs/:id"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete key pair (OpenStack cloud)"  
  ##~ op.nickname = "delete_key_pair"
  ##~ op.parameters.add :name => "id", :description => "Key pair ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of security groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/key_pairs/:id' do
    response = @compute.key_pairs.get(params[:id]).destroy
    [OK, response.to_json]
  end
  
  #
  # Compute Elastic Ips
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe addresses (OpenStack cloud)"  
  ##~ op.nickname = "describe_addresses"
  ##~ op.parameters.add :name => "filters", :description => "Filters for addresses", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of addresses returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/addresses' do
    filters = params[:filters]

    if filters.nil?
      response = @compute.addresses
    else
      response = @compute.addresses.all(filters)
    end

    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create address (OpenStack cloud)"  
  ##~ op.nickname = "create_address"
  ##~ op.errorResponses.add :reason => "Success, address created", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/addresses' do
    json_body = body_to_json(request)
    user_id = Auth.find_account(params[:cred_id]).id
    can_create_instance(
      "cred_id" => params[:cred_id],
      "action"  => "create_address",
      "options" => {
        :instance_count => UserResource.count_resources(user_id,"Elastic IP")
      }
    )

    response = json_body.nil? ?
      @compute.addresses.create :
      @compute.addresses.create(json_body["address"])

    UserResource.create!(
      account_id: user_id,
      resource_id: response.id,
      resource_type: "Elastic IP",
      operation: "create"
    )

    [OK, response.to_json]
  end

  get '/address_pools' do
    response = @compute.list_address_pools
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses/:id"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete address (OpenStack cloud)"  
  ##~ op.nickname = "delete_address"
  ##~ op.parameters.add :name => "id", :description => "Address ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, address deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/addresses/:id' do
    response = @compute.addresses.get(params[:id]).destroy
    UserResource.delete_resource(params[:id])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses/:id/associate/:server_id"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Associate address with server (OpenStack cloud)"  
  ##~ op.nickname = "associate_server_address"
  ##~ op.parameters.add :name => "id", :description => "Address ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "server_id", :description => "Server ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, address and server associated", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/addresses/:id/associate/:server_id' do
    addr = @compute.addresses.get(params[:id])
    response = @compute.associate_address(params[:server_id], addr.ip)
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses/:id/disassociate"
  ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Disassociate address from server (OpenStack cloud)"  
  ##~ op.nickname = "disassociate_address"
  ##~ op.parameters.add :name => "id", :description => "Address ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, address deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/addresses/:id/disassociate' do
    addr = @compute.addresses.get(params[:id])
    addr.server = nil
    [OK, addr.to_json]
  end
end
