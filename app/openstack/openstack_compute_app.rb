require 'sinatra'
require 'fog'

class OpenstackComputeApp < ResourceApiBase

    before do
        if(params[:cred_id].nil?)
            return nil
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                return nil
            else
                options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
                @compute = Fog::Compute.new(options)
                halt [BAD_REQUEST] if @compute.nil?
            end
        end
    end
    
    ##~ sapi = source2swagger.namespace("compute_openstack")
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
    get '/instances' do
        filters = params[:filters]
        if(filters.nil?)
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
    post '/instances' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @compute.servers.create(json_body["instance"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/disassociate_address"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Disassociate address from instance (OpenStack cloud)"  
    ##~ op.nickname = "disassociate_address_instance"
    ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, address associated with instance", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/instances/:id/disassociate_address' do
        json_body = body_to_json(request)
        if(json_body["ip_address"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @compute.disassociate_address(params[:id], json_body["ip_address"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/unpause"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Unpause instance (OpenStack cloud)"  
    ##~ op.nickname = "unpause_instance"
    ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, instance unpaused", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/instances/:id/unpause' do
        begin
            reponse = @compute.unpause_server(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/pause"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Pause instance (OpenStack cloud)"  
    ##~ op.nickname = "pause_instance"
    ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, instance paused", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/instances/:id/pause' do
        begin
            response = @compute.pause_server(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id/reboot"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Reboot instance (OpenStack cloud)"  
    ##~ op.nickname = "reboot_instance"
    ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, instance rebooted", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/instances/:id/reboot' do
        begin
            response = @compute.reboot_server(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/instances/:id"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete instance (OpenStack cloud)"  
    ##~ op.nickname = "delete_instance"
    ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, instance deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    delete '/instances/:id' do
        begin
            response = @compute.servers.get(params[:id]).destroy
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
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
    get '/hosts/describe' do
        response = @compute.list_hosts.body["hosts"].find_all {|h| h["service"] == "@compute"}
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
    get '/security_groups' do
        filters = params[:filters]
        if(filters.nil?)
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
    put '/security_groups' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @compute.security_groups.create(json_body["security_group"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
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
    delete '/security_groups' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["security_group"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @compute.security_groups.get(json_body["security_group"]["id"]).destroy
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
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
    delete '/security_groups/delete_rule' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["rule_id"].nil?)
            [BAD_REQUEST]
        else
            begin
                group = @compute.security_groups.get(json_body["group_id"])
                group.delete_security_group_rule(json_body["rule_id"])
                [OK, @compute.security_groups.get(json_body["group_id"]).to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/security_groups/:id/add_rule"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "PUT"
    ##~ op.summary = "Add security groups rule (OpenStack cloud)"  
    ##~ op.nickname = "add_rule_security_groups"
    ##~ op.parameters.add :name => "id", :description => "Instance ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, security groups rule added", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    put '/security_groups/:id/add_rule' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["rule"].nil?)
            [BAD_REQUEST]
        else
            begin
                rule = json_body["rule"]
                group = @compute.security_groups.get(params[:id])
                group.create_security_group_rule(rule["fromPort"], rule["toPort"], rule["ipProtocol"], rule["cidr"], rule["groupId"])
                [OK, @compute.security_groups.get(params[:id]).to_json]
            rescue => error
                handle_error(error)
            end
        end
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
    ##~ op.parameters.add :name => "name", :description => "Name for key pair", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, key pair named", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/key_pairs' do
        if(params[:name].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @compute.key_pairs.create({"name"=>params[:name]})
                headers["Content-disposition"] = "attachment; filename=" + response.name + ".pem"
                [OK, response.private_key]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/key_pairs/:id"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete key pair (OpenStack cloud)"  
    ##~ op.nickname = "delete_key_pair"
    ##~ op.parameters.add :name => "id", :description => "Key pair ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, list of security groups returned", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    delete '/key_pairs/:id' do
        begin
            response = @compute.key_pairs.get(params[:id]).destroy
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
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
    ##~ op.parameters.add :name => "filters", :description => "Filters for addresses", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, list of addresses returned", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    get '/addresses' do
        filters = params[:filters]
        if(filters.nil?)
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
    post '/addresses' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            response = @compute.addresses.create
        else
            begin
                response = @compute.addresses.create
            rescue => error
                handle_error(error)
            end
        end
        [OK, response.to_json]
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses/:id"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete address (OpenStack cloud)"  
    ##~ op.nickname = "delete_address"
    ##~ op.parameters.add :name => "id", :description => "Address ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, address deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    delete '/addresses/:id' do
        begin
            response = @compute.addresses.get(params[:id]).destroy
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses/:id/associate/:server_id"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Associate address with server (OpenStack cloud)"  
    ##~ op.nickname = "associate_server_address"
    ##~ op.parameters.add :name => "id", :description => "Address ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.parameters.add :name => "server_id", :description => "Server ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, address and server associated", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/addresses/:id/associate/:server_id' do
        begin
            addr = @compute.addresses.get(params[:id])
            response = @compute.associate_address(params[:server_id], addr.ip)
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/compute/addresses/:id/disassociate"
    ##~ a.description = "Manage compute resources on the cloud (OpenStack)"
    ##~ op = a.operations.add
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Disassociate address from server (OpenStack cloud)"  
    ##~ op.nickname = "disassociate_address"
    ##~ op.parameters.add :name => "id", :description => "Address ID", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, address deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
    post '/addresses/:id/disassociate' do
        begin
            addr = @compute.addresses.get(params[:id])
            addr.server = nil
            [OK, addr.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    def body_to_json(request)
        if(!request.content_length.nil? && request.content_length != "0")
            return MultiJson.decode(request.body.read)
        else
            return nil
        end
    end

end
