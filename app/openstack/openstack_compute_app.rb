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
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
    
    post '/instances/:id/unpause' do
        begin
            reponse = @compute.unpause_server(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    post '/instances/:id/pause' do
        begin
            response = @compute.pause_server(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    post '/instances/:id/reboot' do
        begin
            response = @compute.reboot_server(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
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
    get '/address_pools' do
        response = @compute.list_address_pools.body["floating_ip_pools"]
        [OK, response.to_json]
    end
    
    #
    # Compute Host
    #
    get '/hosts/describe' do
        response = @compute.list_hosts.body["hosts"].find_all {|h| h["service"] == "@compute"}
        [OK, response.to_json]
    end
    
    #
    # Compute Flavors
    #
    get '/flavors/describe' do
        response = @compute.flavors
        [OK, response.to_json]
    end
    
    #
    # Compute Security Group
    #
    get '/security_groups' do
        filters = params[:filters]
        if(filters.nil?)
            response = @compute.security_groups
        else
            response = @compute.security_groups.all(filters)
        end
        [OK, response.to_json]
    end
    
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
    get '/key_pairs' do
        response = @compute.key_pairs
        [OK, response.to_json]
    end
    
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
    get '/addresses' do
        filters = params[:filters]
        if(filters.nil?)
            response = @compute.addresses
        else
            response = @compute.addresses.all(filters)
        end
        [OK, response.to_json]
    end
    
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
    
    delete '/addresses/:id' do
        begin
            response = @compute.addresses.get(params[:id]).destroy
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    post '/addresses/:id/associate/:server_id' do
        begin
            addr = @compute.addresses.get(params[:id])
            response = @compute.associate_address(params[:server_id], addr.ip)
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
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
