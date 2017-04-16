require 'sinatra'
require 'fog'

class TopStackLoadBalancerApp < ResourceApiBase

  before do
    params["provider"] = "topstack"
    params["service_type"] = "ELB"
    @service_long_name = "Scalable Load Balancer"
    @service_class = Fog::AWS::ELB
    @elb = can_access_service(params)
  end

  #
  # Load Balancers
  #
  ##~ sapi = source2swagger.namespace("topstack_load_balancer")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["LoadBalancer"] = {:id => "LoadBalancer", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Load Balancers (Topstack cloud)"
  ##~ op.nickname = "describe_load_balancers"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of load balancers returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/load_balancers' do
    filters = params[:filters]
    if(filters.nil?)
      response = @elb.load_balancers
    else
      response = @elb.load_balancers.all(filters)
    end
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Load Balancer (Topstack cloud)"
  ##~ op.nickname = "create_load_balancers"
  ##~ sapi.models["Listener"] = {:id => "Listener", :properties => {:Protocol => {:type => "string"},:LoadBalancerPort => {:type => "int"},:InstancePort => {:type => "int"},:InstanceProtocol => {:type => "string"},:SSLCertificateId => {:type => "string"}}}
  ##~ sapi.models["CreateLoadBalancer"] = {:id => "CreateLoadBalancer", :properties => {:availability_zones => {:type => "Array", :items => {:$ref => "string"}}, :id => {:type => "string"}, :listeners => {:type => "Array", :items => {:$ref => "Listener"}}}}  
  ##~ op.parameters.add :name => "load_balancer", :description => "Load Balancer to Create", :dataType => "CreateLoadBalancer", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, load balancers created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers' do
    json_body = body_to_json_or_die("body" => request)
    user_id = Auth.find_account(params[:cred_id]).id
    region  = get_creds(params[:cred_id]).cloud_account.default_region
    lb = json_body["load_balancer"]
    lb["availability_zones"] = [region]

    can_create_instance(
      "cred_id" => params[:cred_id],
      "action" => "create_load_balancer",
      "options" => {
        :instance_count => UserResource.count_resources(
          user_id, "Scalable Load Balancer"
        )
      }
    )

    if lb["options"].nil?
      response = @elb.create_load_balancer(
        lb["availability_zones"],
        lb["id"],
        lb["listeners"]
      )
    else
      response = @elb.create_load_balancer(
        lb["availability_zones"],
        lb["id"],
        lb["listeners"],
        lb["options"]
      )
    end

    UserResource.create!(
      account_id: user_id,
      resource_id: lb["id"],
      resource_type: "Scalable Load Balancer",
      operation: "create"
    ) 

    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Load Balancers (Topstack cloud)"
  ##~ op.nickname = "delete_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, load balancer deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/load_balancers/:id' do
    response = @elb.load_balancers.get(params[:id]).destroy
    UserResource.delete_resource(params[:id])
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/configure_health_check"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Configure Health Check on Load Balancers (Topstack cloud)"
  ##~ op.nickname = "config_healthcheck_load_balancers"
  ##~ sapi.models["ConfigHealthCheck"] = {:id => "ConfigHealthCheck", :properties => {:HealthyThreshold => {:type => "int"},:Interval => {:type => "int"},:Target => {:type => "string"},:Timeout => {:type => "int"},:UnhealthyThreshold => {:type => "int"}}}  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "health_check", :description => "Health Check params", :dataType => "ConfigHealthCheck", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer health check configured", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers/:id/configure_health_check' do
    json_body = body_to_json_or_die("body" => request)
    response = @elb.configure_health_check(params[:id], json_body["health_check"])
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/availability_zones/enable"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Enable Availability Zone for Load Balancers (Topstack cloud)"
  ##~ op.nickname = "enable_zone_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "availability_zones", :description => "Availability zones", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer zone enabled", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers/:id/availability_zones/enable' do
    json_body = body_to_json_or_die(
      "body" => request,
      "args" => ["availability_zones"]
    )

    response = @elb.enable_availability_zones_for_load_balancer(
      json_body["availability_zones"],
      params[:id]
    )
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/availability_zones/disable"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Disable Availability Zone for Load Balancers (Topstack cloud)"
  ##~ op.nickname = "disable_zone_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "availability_zones", :description => "Availability zones", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer zone disabled", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers/:id/availability_zones/disable' do
    json_body = body_to_json_or_die(
      "body" => request,
      "args" => ["availability_zones"]
    )

    response = @elb.disable_availability_zones_for_load_balancer(
      json_body["availability_zones"],
      params[:id]
    )
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/instances/register"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Register Instances for Load Balancers (Topstack cloud)"
  ##~ op.nickname = "register_instances_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "instance_ids", :description => "Instance ID's", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer instances registered", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers/:id/instances/register' do
    json_body = body_to_json_or_die(
      "body" => request,
      "args" => ["instance_ids"]
    )

    response = @elb.register_instances_with_load_balancer(
      json_body["instance_ids"],
      params[:id]
    )
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/instances/deregister"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "DeRegister Instances for Load Balancers (Topstack cloud)"
  ##~ op.nickname = "deregister_instances_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "instance_ids", :description => "Instance ID's", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer instances deregistered", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers/:id/instances/deregister' do
    json_body = body_to_json_or_die(
      "body" => request,
      "args" => ["instance_ids"]
    )

    response = @elb.deregister_instances_from_load_balancer(
      json_body["instance_ids"],
      params[:id]
    )
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/describe_health"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Health for Load Balancers (Topstack cloud)"
  ##~ op.nickname = "describe_health_load_balancers"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => ":cred_id", :description => "Cred ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":region", :description => "Region", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => ":availability_zones", :description => "availability zone's", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, load balancer health description returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/load_balancers/:id/describe_health' do
    halt [BAD_REQUEST] if params[:availability_zones].nil?
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

    instance_health = @elb.describe_instance_health(
      params[:id]
    ).body["DescribeInstanceHealthResult"]["InstanceStates"]
    get_compute_interface(params[:cred_id])

    instance_health.each do |i|
      instance = @compute.servers.get(i["InstanceId"])
      unless instance.nil?
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

    response = {
      "AvailabilityZonesHealth" => availability_zones_health,
      "InstancesHealth" => instance_health
    }
    [OK, response.to_json]
  end

  #
  # Load Balancer Listeners
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/listeners"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Load Balancer Listeners (Topstack cloud)"
  ##~ op.nickname = "describe_load_balancer_listeners"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to get listeners for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of load balancer listeners returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/load_balancers/:id/listeners' do
    response = @elb.load_balancers.get(params[:id]).listeners
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/listeners"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Load Balancer Listeners (Topstack cloud)"
  ##~ op.nickname = "create_load_balancer_listeners"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to create listeners for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => ":listeners", :description => "listeners", :dataType => "Array", :items => {:$ref => "Listener"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer listeners created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/load_balancers/:id/listeners' do
    json_body = body_to_json_or_die("body" => request)
    response = @elb.create_load_balancer_listeners(
      params[:id],
      json_body["listeners"]
    )
    [OK, response.to_json]
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/topstack/load_balancer/load_balancers/:id/listeners"
  ##~ a.description = "Manage Load Balancer resources on the cloud (Topstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Load Balancer Listeners (Topstack cloud)"
  ##~ op.nickname = "delete_load_balancer_listeners"  
  ##~ op.parameters.add :name => "id", :description => "Load Balancer ID to delete listeners for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => ":ports", :description => "ports", :dataType => "Array", :items => {:$ref => "string"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, load balancer listeners deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/load_balancers/:id/listeners' do
    json_body = body_to_json_or_die("body" => request)
    response = @elb.delete_load_balancer_listeners(params[:id], json_body["ports"])
    [OK, response.to_json]
  end

  def get_compute_interface(cred_id)
    cloud_cred = get_creds(params[:cred_id])
    return if cloud_cred.nil?

    options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
    @compute = Fog::Compute.new(options)
    halt [BAD_REQUEST] if @compute.nil?
  end
end
