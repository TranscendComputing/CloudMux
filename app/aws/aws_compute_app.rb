require 'sinatra'
require 'fog'

class AwsComputeApp < ResourceApiBase
	#
	# Compute Instance
	#
    ##~ sapi = source2swagger.namespace("compute_aws")
    ##~ sapi.swaggerVersion = "1.1"
    ##~ sapi.apiVersion = "1.0"

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/compute/instances/describe"
    ##~ a.description = "Manage compute resources on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe current instances (AWS cloud)"  
    ##~ op.nickname = "describe_instances"
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "filters", :description => "Filters for instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, list of instances returned", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/instances/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.servers
			else
				response = compute.servers.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/compute/instances/create"
    ##~ a.description = "Manage compute resources on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "PUT"
    ##~ op.summary = "Run a new instance (AWS cloud)"  
    ##~ op.nickname = "run_instance"
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, new instance returned", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400	
	put '/instances/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.servers.create(json_body["instance"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/instances/start"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Starts an instance (AWS cloud)"
	##~ op.nickname = "start_instance"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, instance started", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	post '/instances/start' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.servers.get(json_body["instance"]["id"]).start
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/instances/stop"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Stops an instance (AWS cloud)"
	##~ op.nickname = "stop_instance"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, instance stopped", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	post '/instances/stop' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.servers.get(json_body["instance"]["id"]).stop
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/instances/reboot"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Reboots an instance (AWS cloud)"
	##~ op.nickname = "reboot_instance"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, instance rebooted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	post '/instances/reboot' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.servers.get(json_body["instance"]["id"]).reboot
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/instances/terminate"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Terminates an instance (AWS cloud)"
	##~ op.nickname = "terminate_instance"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, instance terminated", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	delete '/instances/terminate' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["instance"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.servers.get(json_body["instance"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# Compute Availability Zones
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/availability_zones/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current availability zones (AWS cloud)"
	##~ op.nickname = "describe_availability_zones"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for availability zones", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of availability zones returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/availability_zones/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.describe_availability_zones.body["availabilityZoneInfo"]
			else
				response = compute.describe_availability_zones(filters).body["availabilityZoneInfo"]
			end
			[OK, response.to_json]
		end
	end
	
	#
	# Compute Flavors
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/flavors/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current flavors (AWS cloud)"
	##~ op.nickname = "describe_flavors"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of flavors returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/flavors/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			response = compute.flavors
			[OK, response.to_json]
		end
	end
	
	#
	# Compute Security Group
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/security_groups/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current security groups (AWS cloud)"
	##~ op.nickname = "describe_security_groups"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for security groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of security groups returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/security_groups/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.security_groups
			else
				response = compute.security_groups.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/security_groups/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Create new security group (AWS cloud)"
	##~ op.nickname = "create_security_group"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new security group returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/security_groups/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.security_groups.create(json_body["security_group"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/security_groups/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Deletes security group (AWS cloud)"
	##~ op.nickname = "delete_security_group"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, security group deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	delete '/security_groups/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["security_group"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.security_groups.get(json_body["security_group"]["name"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	
	#
	# Compute Key Pairs
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/key_pairs/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current key pairs (AWS cloud)"
	##~ op.nickname = "describe_key_pairs"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for key pairs", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of key pairs returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/key_pairs/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.key_pairs
			else
				response = compute.key_pairs.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/key_pairs/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Creates key pair (AWS cloud)"
	##~ op.nickname = "create_key_pair"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "name", :description => "Name to give key pair", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, instance terminated", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	post '/key_pairs/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			if(params[:name].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.key_pairs.create({"name"=>params[:name]})
					headers["Content-disposition"] = "attachment; filename=" + response.name + ".pem"
					[OK, response.private_key]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/key_pairs/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Deletes key pair (AWS cloud)"
	##~ op.nickname = "delete_key_pair"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, key pair deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	delete '/key_pairs/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["key_pair"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.key_pairs.get(json_body["key_pair"]["name"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# Compute Spot Requests
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/spot_requests/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current spot requests (AWS cloud)"
	##~ op.nickname = "describe_spot_requests"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for spot requests", :dataType => "string", :allowMulitple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of spot requests returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/spot_requests/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.spot_requests
			else
				response = compute.spot_requests.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/spot_requests/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Run new spot request (AWS cloud)"
	##~ op.nickname = "run_spot_request"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new spot request returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/spot_requests/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.spot_requests.create(json_body["spot_request"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/spot_requests/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Delete spot request (AWS cloud)"
	##~ op.nickname = "delete_spot_request"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, instance terminated", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	delete '/spot_requests/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["spot_request"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.spot_requests.get(json_body["spot_request"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/spot_prices/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe spot price history (AWS cloud)"
	##~ op.nickname = "describe_spot_prices"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for spot prices", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, history of spot prices returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/spot_prices/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.describe_spot_price_history.body["spotPriceHistorySet"]
			else
				response = compute.describe_spot_price_history(filters).body["spotPriceHistorySet"]
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/spot_prices/current"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Returns current spot prices (AWS cloud)"
	##~ op.nickname = "current_spot_prices"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, current spot prices returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	post '/spot_prices/current' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["filters"].nil?)
				[BAD_REQUEST]
			else
				filters = json_body["filters"]
				response = compute.describe_spot_price_history(filters).body["spotPriceHistorySet"].first
				[OK, response.to_json]
			end
		end
	end
	
	#
	# Compute Elastic Ips
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/addresses/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current addresses (AWS cloud)"
	##~ op.nickname = "describe_addresses"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for addresses", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of addresses returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/addresses/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.addresses
			else
				response = compute.addresses.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/addresses/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Create new address (AWS cloud)"
	##~ op.nickname = "create_address"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new address returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	put '/addresses/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				response = compute.addresses.create
			else
				begin
					response = compute.addresses.create(json_body["address"])
				rescue => error
					handle_error(error)
				end
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/addresses/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Delete address (AWS cloud)"
	##~ op.nickname = "delete_address"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, address deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	delete '/addresses/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["address"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.addresses.get(json_body["address"]["public_ip"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/addresses/associate"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Associate addresses (AWS cloud)"
	##~ op.nickname = "associate_addresses"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, addresses associated", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	post '/addresses/associate' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["address"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.associate_address(json_body["address"]["server_id"], json_body["address"]["public_ip"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/addresses/dissassoicate"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Disassociate addresses (AWS cloud)"
	##~ op.nickname = "disassociate_addresses"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, addresses disassociated", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	post '/addresses/disassociate' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["address"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.disassociate_address(json_body["address"]["public_ip"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# Compute Reserved Instances
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/reserved_instances/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current reserved instances (AWS cloud)"
	##~ op.nickname = "describe_reserved_instances"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for reserved instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of reserved instances returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/reserved_instances/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.describe_reserved_instances.body["reservedInstanceSet"]
			else
				response = compute.describe_reserved_instances(filters).body["reservedInstanceSet"]
			end
			[OK, response.to_json]
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/reserved_instances/describe_offerings"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe offerings of current reserved instances (AWS cloud)"
	##~ op.nickname = "describe_offerings_reserved_instances"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for reserved instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of offerings returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/reserved_instances/describe_offerings' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.describe_reserved_instances_offerings.body["reservedInstancesOfferingsSet"]
			else
				response = compute.describe_reserved_instances_offerings(filters).body["reservedInstancesOfferingsSet"]
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/reserved_instances/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Run new reserved instance (AWS cloud)"
	##~ op.nickname = "run_reserved_instance"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new reserved instance returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/reserved_instances/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.purchase_reserved_instances_offering(json_body["reserved_instances_offering_id"], json_body["instance_count"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# VPCs
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/vpcs/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current VPCs (AWS cloud)"
	##~ op.nickname = "describe_vpcs"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for VPCs", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of VPCs returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/vpcs/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.vpcs
			else
				response = compute.vpcs.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/vpcs/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Create new VPC (AWS cloud)"
	##~ op.nickname = "create_vpc"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new VPC returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/vpcs/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					if(json_body["vpc"]["InstanceTenancy"].nil?)
						options = {}
					else
						options = {"InstanceTenancy"=>json_body["vpc"]["InstanceTenancy"]}
					end
					response = compute.create_vpc(json_body["vpc"]["CidrBlock"], options)
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/vpcs/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Delete VPC (AWS cloud)"
	##~ op.nickname = "delete_vpc"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, VPC deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	delete '/vpcs/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["vpc"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.vpcs.get(json_body["vpc"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/vpcs/associate_dhcp_options"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Associate DHCP options with VPC (AWS cloud)"
	##~ op.nickname = "associate_dhcp_options_vpcs"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, DHCP options and VPC associated", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	post '/vpcs/associate_dhcp_options' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["vpc"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.associate_dhcp_options(json_body["vpc"]["dhcp_options_id"], json_body["vpc"]["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# DHCPs
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/dhcp_options/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current DHCP options (AWS cloud)"
	##~ op.nickname = "describe_dhcp_options"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for DHCP options", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of DHCP options returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/dhcp_options/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.dhcp_options
			else
				response = compute.dhcp_options.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/dhcp_options/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Create new DHCP option (AWS cloud)"
	##~ op.nickname = "create_dhcp_option"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new DHCP option returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/dhcp_options/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.dhcp_options.create(json_body["dhcp_option"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/chcp_options/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Delete DHCP option (AWS cloud)"
	##~ op.nickname = "delete_dhcp_option"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, DHCP option deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	delete '/dhcp_options/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["dhcp_option"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.dhcp_options.get(json_body["dhcp_option"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# Internet Gateways
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/internet_gateways/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current internet gateways (AWS cloud)"
	##~ op.nickname = "describe_internet_gateways"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramTypes => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for internet gateways", :dataType => "string", :allowMultiple => false, :required => false, :paramTypes => "query"
	##~ op.errorResponses.add :reason => "Success, list of internet gateways returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/internet_gateways/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.internet_gateways
			else
				response = compute.internet_gateways.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/internet_gateways/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Create new internet gateway (AWS cloud)"
	##~ op.nickname = "create_internet_gateway"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new internet gateway returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/internet_gateways/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			begin
				response = compute.internet_gateways.create
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/internet_gateways/attach"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Attach internet gateway (AWS cloud)"
	##~ op.nickname = "attach_internet_gateway"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, internet gateway attached", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	post '/internet_gateways/attach' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["internet_gateway"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.attach_internet_gateway(json_body["internet_gateway"]["id"], json_body["internet_gateway"]["vpc_id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/internet_gateways/detach"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "POST"
	##~ op.summary = "Detach internet gateway (AWS cloud)"
	##~ op.nickname = "detach_internet gateway"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, internet gateway detached", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	post '/internet_gateways/detach' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["internet_gateway"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.detach_internet_gateway(json_body["internet_gateway"]["id"], json_body["internet_gateway"]["vpc_id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/internet_gateways/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Delete internet gateway (AWS cloud)"
	##~ op.nickname = "delete_internet_gateway"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, internet gateway deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	delete '/internet_gateways/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["internet_gateway"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.internet_gateways.get(json_body["internet_gateway"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# Subnets
	#

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/subnets/describe"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "GET"
	##~ op.summary = "Describe current subnets (AWS cloud)"
	##~ op.nickname = "describe_subnets"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "filters", :description => "Filters for subnets", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, list of subnets returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	get '/subnets/describe' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = compute.subnets
			else
				response = compute.subnets.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/subnets/create"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "PUT"
	##~ op.summary = "Create new subnet (AWS cloud)"
	##~ op.nickname = "create_subnet"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, new subnet returned", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
	put '/subnets/create' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.subnets.create(json_body["subnet"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	##~ a = sapi.apis.add
	##~ a.set :path => "/api/v1/cloud_management/aws/compute/subnets/delete"
	##~ a.description = "Manage compute resources on the cloud (AWS)"
	##~ op = a.operations.add
	##~ op.set :httpMethod => "DELETE"
	##~ op.summary = "Delete subnet (AWS cloud)"
	##~ op.nickname = "delete_subnet"
	##~ op.parameters.add :name => "cred_id", :description => "Cloud credentials to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	##~ op.errorResponses.add :reason => "Success, subnet deleted", :code => 200
	##~ op.errorResponses.add :reason => "Credentials not supported by cloud", code => 400
	delete '/subnets/delete' do
		compute = get_compute_interface(params[:cred_id], params[:region])
		if(compute.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["subnet"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = compute.subnets.get(json_body["subnet"]["subnet_id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	def get_compute_interface(cred_id, region)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				if region.nil? or region == "undefined" or region == ""
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
				end
			end
		end
	end
end
