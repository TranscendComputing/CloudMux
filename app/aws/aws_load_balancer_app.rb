require 'sinatra'
require 'fog'

class AwsLoadBalancerApp < ResourceApiBase

	before do
    params["provider"] = "aws"
    @service_long_name = "Elastic Load Balancer"
    @service_class = Fog::AWS::ELB
    @elb = can_access_service(params)
  end

	#
	# Load Balancers
	#
  ##~ sapi = source2swagger.namespace("aws_load_balancer")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Load Balancers (AWS cloud)"
  ##~ op.nickname = "describe_load_balancers"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of load balancers returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/load_balancers' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @elb.load_balancers
  		else
  			response = @elb.load_balancers.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Load Balancer (AWS cloud)"
  ##~ op.nickname = "create_load_balancers"
  ##~ sapi.models["Listener"] = {:id => "Listener", :properties => {:Protocol => {:type => "string"},:LoadBalancerPort => {:type => "int"},:InstancePort => {:type => "int"},:InstanceProtocol => {:type => "string"},:SSLCertificateId => {:type => "string"}}}
  ##~ sapi.models["CreateLoadBalancer"] = {:id => "CreateLoadBalancer", :properties => {:availability_zones => {:type => "Array", :items => {:$ref => "string"}}, :id => {:type => "string"}, :listeners => {:type => "Array", :items => {:$ref => "Listener"}}}}  
  ##~ op.parameters.add :name => "load_balancer", :description => "Load Balancer to Create", :dataType => "CreateLoadBalancer", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, load balancers created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers' do
		json_body = body_to_json_or_die("body" => request)
		begin
			lb = json_body["load_balancer"]
			if lb["options"].nil?
				response = @elb.create_load_balancer(lb["availability_zones"], lb["id"], lb["listeners"])
			else
				response = @elb.create_load_balancer(lb["availability_zones"], lb["id"], lb["listeners"], lb["options"])
			end
              Auth.validate(params[:cred_id],"Elastic Load Balancer","create_default_alarms",{:params => params, :resource_id => lb["id"], :namespace => "AWS/ELB"})
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Load Balancers (AWS cloud)"
  ##~ op.nickname = "delete_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, load balancer deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/load_balancers/:id' do
		begin
			response = @elb.load_balancers.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/configure_health_check"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Configure Health Check on Load Balancers (AWS cloud)"
  ##~ op.nickname = "config_healthcheck_load_balancers"
  ##~ sapi.models["ConfigHealthCheck"] = {:id => "ConfigHealthCheck", :properties => {:HealthyThreshold => {:type => "int"},:Interval => {:type => "int"},:Target => {:type => "string"},:Timeout => {:type => "int"},:UnhealthyThreshold => {:type => "int"}}}  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "health_check", :description => "Health Check params", :dataType => "ConfigHealthCheck", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer health check configured", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers/:id/configure_health_check' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @elb.configure_health_check(params[:id], json_body["health_check"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/availability_zones/enable"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Enable Availability Zone for Load Balancers (AWS cloud)"
  ##~ op.nickname = "enable_zone_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "availability_zones", :description => "Availability zones", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer zone enabled", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers/:id/availability_zones/enable' do
		json_body = body_to_json_or_die("body" => request, "args" => ["availability_zones"])
		begin
			response = @elb.enable_availability_zones_for_load_balancer(json_body["availability_zones"], params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/availability_zones/disable"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Disable Availability Zone for Load Balancers (AWS cloud)"
  ##~ op.nickname = "disable_zone_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "availability_zones", :description => "Availability zones", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer zone disabled", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers/:id/availability_zones/disable' do
		json_body = body_to_json_or_die("body" => request, "args" => ["availability_zones"])
		begin
			response = @elb.disable_availability_zones_for_load_balancer(json_body["availability_zones"], params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/instances/register"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Register Instances for Load Balancers (AWS cloud)"
  ##~ op.nickname = "register_instances_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "instance_ids", :description => "Instance ID's", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer instances registered", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers/:id/instances/register' do
		json_body = body_to_json_or_die("body" => request, "args" => ["instance_ids"])
		begin
			response = @elb.register_instances_with_load_balancer(json_body["instance_ids"], params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/instances/deregister"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "DeRegister Instances for Load Balancers (AWS cloud)"
  ##~ op.nickname = "deregister_instances_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "instance_ids", :description => "Instance ID's", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer instances deregistered", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers/:id/instances/deregister' do
		json_body = body_to_json_or_die("body" => request, "args" => ["instance_ids"])
		begin
			response = @elb.deregister_instances_from_load_balancer(json_body["instance_ids"], params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/describe_health"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Health for Load Balancers (AWS cloud)"
  ##~ op.nickname = "describe_health_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => ":cred_id", :description => "Cred ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":region", :description => "Region", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":availability_zones", :description => "availability zone's", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, load balancer health description returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/load_balancers/:id/describe_health' do
		if(params[:availability_zones].nil?)
			[BAD_REQUEST]
		else
			begin
				availability_zones_health = []
				availability_zones = JSON.parse(params[:availability_zones])
				availability_zones.each do |az|
					az_health = {}
					az_health["LoadBalancerName"] = params[:id]
					az_health["AvailabilityZone"] = az
					az_health["InstanceCount"] = 0
					az_health["Healthy"] = false
					availability_zones_health << az_health
				end
				instance_health = @elb.describe_instance_health(params[:id]).body["DescribeInstanceHealthResult"]["InstanceStates"]
				compute = get_compute_interface(params[:cred_id], params[:region])
				instance_health.each do |i|
					instance = compute.servers.get(i["InstanceId"])
					if(!instance.nil?)
						i["AvailabilityZone"] = instance.availability_zone
						availability_zones_health.each do |a|
							if a["AvailabilityZone"] == i["AvailabilityZone"]
								a["InstanceCount"] = a["InstanceCount"] + 1
								if i["State"] == "InService"
									a["Healthy"] = true
								end
							end
						end
					end
				end
				response = {"AvailabilityZonesHealth" => availability_zones_health, "InstancesHealth" => instance_health}
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	#
	# Load Balancer Listeners
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/listeners"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Load Balancer Listeners (AWS cloud)"
  ##~ op.nickname = "describe_load_balancer_listeners"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to get listeners for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of load balancer listeners returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/load_balancers/:id/listeners' do
		begin
			response = @elb.load_balancers.get(params[:id]).listeners
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/listeners"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Load Balancer Listeners (AWS cloud)"
  ##~ op.nickname = "create_load_balancer_listeners"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to create listeners for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => ":listeners", :description => "listeners", :dataType => "Array", :items => {:$ref => "Listener"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer listeners created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/load_balancers/:id/listeners' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @elb.create_load_balancer_listeners(params[:id], json_body["listeners"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/load_balancer/load_balancers/:id/listeners"
  ##~ a.description = "Manage Load Balancer resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Load Balancer Listeners (AWS cloud)"
  ##~ op.nickname = "delete_load_balancer_listeners"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to delete listeners for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => ":ports", :description => "ports", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer listeners deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/load_balancers/:id/listeners' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @elb.delete_load_balancer_listeners(params[:id], json_body["ports"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
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
