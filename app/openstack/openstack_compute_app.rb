require 'sinatra'
require 'fog'

class OpenstackComputeApp < ResourceApiBase
    
    get '/instances/describe' do
        compute = get_compute_interface(params[:cred_id])
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
    
    put '/instances/create' do
        compute = get_compute_interface(params[:cred_id])
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
    
    post '/instances/start' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            json_body = body_to_json(request)
            if(json_body.nil? || json_body["instance"].nil?)
                [BAD_REQUEST]
            else
                begin
                    reponse = compute.unpause_server(json_body["instance"]["id"])
                    [OK, response.to_json]
                rescue => error
                    handle_error(error)
                end
            end
        end
    end
    
    post '/instances/stop' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            json_body = body_to_json(request)
            if(json_body.nil? || json_body["instance"].nil?)
                [BAD_REQUEST]
            else
                begin
                    response = compute.pause_server(json_body["instance"]["id"])
                    [OK, response.to_json]
                rescue => error
                    handle_error(error)
                end
            end
        end
    end
    
    post '/instances/reboot' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            json_body = body_to_json(request)
            if(json_body.nil? || json_body["instance"].nil?)
                [BAD_REQUEST]
            else
                begin
                    response = compute.reboot_server(json_body["instance"]["id"])
                    [OK, response.to_json]
                rescue => error
                    handle_error(error)
                end
            end
        end
    end
    
    delete '/instances/terminate' do
        compute = get_compute_interface(params[:cred_id])
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
    # Compute Host
    #
    get '/hosts/describe' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            response = compute.list_hosts.body["hosts"].find_all {|h| h["service"] == "compute"}
            [OK, response.to_json]
        end
    end
    
    #
    # Compute Flavors
    #
    get '/flavors/describe' do
        compute = get_compute_interface(params[:cred_id])
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
    get '/security_groups' do
        compute = get_compute_interface(params[:cred_id])
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
    
    put '/security_groups' do
        compute = get_compute_interface(params[:cred_id])
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
    
    delete '/security_groups' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            json_body = body_to_json(request)
            if(json_body.nil? || json_body["security_group"].nil?)
                [BAD_REQUEST]
            else
                begin
                    response = compute.security_groups.get(json_body["security_group"]["id"]).destroy
                    [OK, response.to_json]
                rescue => error
                    handle_error(error)
                end
            end
        end
    end

    delete '/security_groups/delete_rule' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            json_body = body_to_json(request)
            if(json_body.nil? || json_body["rule_id"].nil?)
                [BAD_REQUEST]
            else
                begin
                    group = compute.security_groups.get(json_body["group_id"])
                    group.delete_security_group_rule(json_body["rule_id"])
                    [OK, compute.security_groups.get(json_body["group_id"]).to_json]
                rescue => error
                    handle_error(error)
                end
            end
        end
    end

    put '/security_groups/:id/add_rule' do
        compute = get_compute_interface(params[:cred_id])
        if(compute.nil?)
            [BAD_REQUEST]
        else
            json_body = body_to_json(request)
            if(json_body.nil? || json_body["rule"].nil?)
                [BAD_REQUEST]
            else
                begin
                    rule = json_body["rule"]
                    group = compute.security_groups.get(params[:id])
                    group.create_security_group_rule(rule["fromPort"], rule["toPort"], rule["ipProtocol"], rule["cidr"], rule["groupId"])
                    [OK, compute.security_groups.get(params[:id]).to_json]
                rescue => error
                    handle_error(error)
                end
            end
        end
    end
    
    
    #
    # Compute Key Pairs
    #
    get '/key_pairs/describe' do
        compute = get_compute_interface(params[:cred_id])
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
    
    post '/key_pairs/create' do
        compute = get_compute_interface(params[:cred_id])
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
    
    delete '/key_pairs/delete' do
        compute = get_compute_interface(params[:cred_id])
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
    # Compute Elastic Ips
    #
    get '/addresses/describe' do
        compute = get_compute_interface(params[:cred_id])
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
    
    put '/addresses/create' do
        compute = get_compute_interface(params[:cred_id])
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
    
    delete '/addresses/delete' do
        compute = get_compute_interface(params[:cred_id])
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
    
    post '/addresses/associate' do
        compute = get_compute_interface(params[:cred_id])
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
    
    post '/addresses/disassociate' do
        compute = get_compute_interface(params[:cred_id])
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
    
    def get_compute_interface(cred_id)
        if(cred_id.nil?)
            return nil
        else
            cloud_cred = get_creds(cred_id)
            if cloud_cred.nil?
                return nil
            else
                options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
                return Fog::Compute.new(options)
            end
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
