require 'sinatra'
require 'fog'

class OpenstackNetworkApp < ResourceApiBase

  before do
    if(params[:cred_id].nil? || ! Auth.validate(params[:cred_id],"Network Service","action"))
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Cannot access this service under current policy."
      halt [NOT_AUTHORIZED, message.to_json]
    else
      cloud_cred = get_creds(params[:cred_id])
      if cloud_cred.nil?
        halt [NOT_FOUND, "Credentials not found."]
      else
        options = cloud_cred.cloud_attributes
        begin
          @network = Fog::Network::OpenStack.new(options)
          halt [BAD_REQUEST] if @network.nil?
        rescue Fog::Errors::NotFound => error
          halt [NOT_FOUND, error.to_s]
        end
      end
    end
  end

  #
  # Networks
  #
  ##~ sapi = source2swagger.namespace("openstack_network")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Network"] = {:id => "Network", :properties => {:id => {:type => "string"}}}
  ##~ sapi.models["Subnet"] = {:id => "Subnet", :properties => {:id => {:type => "string"}}}
  ##~ sapi.models["Port"] = {:id => "Port", :properties => {:id => {:type => "string"}}}
  ##~ sapi.models["FloatingIP"] = {:id => "FloatingIP", :properties => {:id => {:type => "string"}}}
    
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/networks"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Network"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Networks (Openstack cloud)"
  ##~ op.nickname = "describe_networks"  
  ##~ op.errorResponses.add :reason => "Success, list of networks returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/networks' do
    response = @network.list_networks.body["networks"]
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/networks"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Network"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Network (Openstack cloud)"
  ##~ op.nickname = "create_network"
  ##~ sapi.models["CreateNetwork"] = {:id => "CreateNetwork", :properties => {:name => {:type => "string"}, :tenant_id => {:type => "int"}, :admin_state_up => {:type => "boolean"}, :shared => {:type => "boolean"}}}  
  ##~ op.parameters.add :name => "network", :description => "Network to create", :dataType => "CreateNetwork", :allowMultiple => false, :required => true, :paramType => "body"  
  ##~ op.errorResponses.add :reason => "Success, network created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/networks' do
    json_body = body_to_json_or_die("body" => request, "args" => ["network"])
    response = @network.networks.create(json_body["network"])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/networks/:id"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Network"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Network (Openstack cloud)"
  ##~ op.nickname = "delete_network"
  ##~ op.parameters.add :name => "id", :description => "Network id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
  ##~ op.errorResponses.add :reason => "Success, network deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/networks/:id' do
    response = @network.networks.destroy(params[:id])
    [OK, response.to_json]
  end
  
  #
  # Subnets
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/subnets"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Subnet"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Subnets (Openstack cloud)"
  ##~ op.nickname = "describe_subnets"  
  ##~ op.errorResponses.add :reason => "Success, list of subnets returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/subnets' do
    response = @network.list_subnets.body["subnets"]
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/subnets"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Subnet"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Subnet (Openstack cloud)"
  ##~ op.nickname = "create_subnet"
  ##~ sapi.models["CreateSubnet"] = {:id => "CreateSubnet", :properties => {:network_id => {:type => "string"}, :cidr => {:type => "string"}, :ip_version => {:type => "string"}, :gateway_ip => {:type => "string"}, :allocation_pools => {:type => "string"}}}  
  ##~ op.parameters.add :name => "subnet", :description => "Subnet to create", :dataType => "CreateSubnet", :allowMultiple => false, :required => true, :paramType => "body"  
  ##~ op.errorResponses.add :reason => "Success, subnet created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/subnets' do
      json_body = body_to_json_or_die("body" => request, "args" => ["subnet"])
      response = @network.subnets.create(json_body["subnet"])
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/subnets/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Subnet"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Subnet (Openstack cloud)"
    ##~ op.nickname = "delete_subnet"
    ##~ op.parameters.add :name => "id", :description => "Subnet id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, subnet deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/subnets/:id' do
      response = @network.subnets.destroy(params[:id])
      [OK, response.to_json]
    end

    #
    # Ports
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/ports"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Port"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Ports (Openstack cloud)"
    ##~ op.nickname = "describe_ports"  
    ##~ op.errorResponses.add :reason => "Success, list of ports returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    get '/ports' do
      response = @network.list_ports.body["ports"]
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/ports"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Port"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create Port (Openstack cloud)"
    ##~ op.nickname = "create_port"
    ##~ sapi.models["CreatePort"] = {:id => "CreatePort", :properties => {:network_id => {:type => "string"}, :name => {:type => "string"}, :admin_state_up => {:type => "boolean"}}}  
    ##~ op.parameters.add :name => "port", :description => "Port to create", :dataType => "CreatePort", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, port created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/ports' do
      json_body = body_to_json_or_die("body" => request, "args" => ["port"])
      response = @network.ports.create(json_body["port"])
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/ports/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Port"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Port (Openstack cloud)"
    ##~ op.nickname = "delete_port"
    ##~ op.parameters.add :name => "id", :description => "Port id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, port deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/ports/:id' do
      response = @network.ports.destroy(params[:id])
      [OK, response.to_json]
    end

    #
    # Floating IPs
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/floating_ips"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "FloatingIP"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Floating IPs (Openstack cloud)"
    ##~ op.nickname = "describe_floating_ips"  
    ##~ op.errorResponses.add :reason => "Success, list of Floating IPs returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    get '/floating_ips' do
      response = @network.list_floating_ips.body["floating_ips"]
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/floating_ips"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "FloatingIP"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create FloatingIP (Openstack cloud)"
    ##~ op.nickname = "create_floating_ip"
    ##~ sapi.models["CreateFloatingIP"] = {:id => "CreateFloatingIP", :properties => {:name => {:type => "string"}}}  
    ##~ op.parameters.add :name => "floating_ip", :description => "FloatingIP to create", :dataType => "CreateFloatingIP", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, Floating IP created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/floating_ips' do
      json_body = body_to_json_or_die(
        "body" => request,
        "args" => ["floating_ips"]
      )

      response = @network.floating_ips.create(json_body["floating_ip"])
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/floating_ips/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "FloatingIP"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete FloatingIP (Openstack cloud)"
    ##~ op.nickname = "delete_floating_ip"
    ##~ op.parameters.add :name => "id", :description => "FloatingIP id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, Floating IP deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/floating_ips/:id' do
      response = @network.floating_ips.destroy(params[:id])
      [OK, response.to_json]
    end

    #
    # Routers
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/routers"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Routers"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Routers (Openstack cloud)"
    ##~ op.nickname = "describe_routers"  
    ##~ op.errorResponses.add :reason => "Success, list of Routers returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    get '/routers' do
      response = @network.routers
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/routers"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Routers"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create Routers (Openstack cloud)"
    ##~ op.nickname = "create_routers"
    ##~ sapi.models["CreateRouters"] = {:id => "CreateRouter", :properties => {:name => {:type => "string"}}}  
    ##~ op.parameters.add :name => "router", :description => "Router to create", :dataType => "CreateRouter", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, Router created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/routers' do
      json_body = body_to_json_or_die("body" => request, "args" => ["router"])
      response = @network.routers.create(json_body["router"])
      [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/routers/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Routers"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Routers (Openstack cloud)"
    ##~ op.nickname = "delete_routers"
    ##~ op.parameters.add :name => "id", :description => "Router id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, Router deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/routers/:id' do
      delete_all_interfaces(params)
      response = @network.routers.destroy(params[:id])
      [OK, response.to_json]
    end

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/routers/:id/add_router_interface"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Routers"
    ##~ op.set :httpMethod => "PUT"
    ##~ op.summary = "Add Router Interface (Openstack cloud)"
    ##~ op.nickname = "add_router_interface"  
    ##~ op.parameters.add :name => "id", :description => "Interface to create", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, Router interface added", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    put '/routers/:id/add_router_interface' do
      json_body = body_to_json_or_die("body" => request, "args" => ["router"])
      response = @network.add_router_interface(
        params[:id],
        json_body["router"]["subnet_id"]
      )
      [OK, response.to_json]
    end

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/routers/:id/remove_router_interface"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Routers"
    ##~ op.set :httpMethod => "PUT"
    ##~ op.summary = "Remove Router Interface (Openstack cloud)"
    ##~ op.nickname = "remove_router_interface"  
    ##~ op.parameters.add :name => "router", :description => "Interface to remove", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, Router interface removed", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    put '/routers/:id/remove_router_interface' do
      json_body = body_to_json_or_die("body" => request, "args" => ["router"])
      response = @network.remove_router_interface(
        params[:id],
        json_body["router"]["subnet_id"]
      )
      [OK, response.to_json]
    end

    # ##~ a = sapi.apis.add
    # ##~ a.set :path => "/api/v1/cloud_management/openstack/network/routers"
    # ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    # ##~ op = a.operations.add
    # ##~ op.responseClass = "Routers"
    # ##~ op.set :httpMethod => "PUT"
    # ##~ op.summary = "Update Routers (Openstack cloud)"
    # ##~ op.nickname = "update_routers"
    # ##~ sapi.models["CreateFloatingIP"] = {:id => "CreateFloatingIP", :properties => {:name => {:type => "string"}}}  
    # ##~ op.parameters.add :name => "floating_ip", :description => "FloatingIP to create", :dataType => "CreateFloatingIP", :allowMultiple => false, :required => true, :paramType => "body"  
    # ##~ op.errorResponses.add :reason => "Success, Router updated", :code => 200
    # ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    # ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    # put '/routers/:id' do
    #   json_body = body_to_json_or_die("body" => request, "args" => ["router"])
    #   begin
    #     response = @network.routers.update(json_body["router"])
    #     [OK, response.to_json]
    #   rescue => error
    #     handle_error(error)
    #   end
    # end

    #Helper function when a router gets deleted and still has interfaces.
    #parameters router Id.
    def delete_all_interfaces(params)
      interfaces = @network.ports.all({:device_id => params[:id]})
      interfaces.each do |interface|
        begin
          @network.remove_router_interface(
            params[:id],
            interface.fixed_ips[0]["subnet_id"]
          )
        rescue => error
          handle_error(error)
        end
      end
    end
end
