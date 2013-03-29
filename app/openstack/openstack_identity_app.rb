require 'sinatra'
require 'fog'

class OpenstackIdentityApp < ResourceApiBase

	before do
        if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
                ## TEMP HACK UNTIL CORRECTY IDENTITY URL IS RESOLVED
                management_url = options["openstack_auth_url"].gsub("/tokens", "")
                @identity = Fog::Identity.new(options.merge({:openstack_management_url => management_url}))
                #@identity = Fog::Identity.new(options.merge({:openstack_endpoint_type => 'publicURL'}))
                halt [BAD_REQUEST] if @identity.nil?
            end
        end
    end

	#
	# Users
	#
    
    # If tenant_id is passed as URL param, then this action is filtered by tenants
    # Otherwise, all users are returned  
	get '/users' do
        begin
            response = @identity.list_users(params[:tenant_id]).body["users"]
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
	post '/users' do
        json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @identity.users.create(json_body["user"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	delete '/users/:id' do
        begin
			response = @identity.users.destroy(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Tenants
	#
	get '/tenants' do
        begin
            response = @identity.list_tenants.body["tenants"]
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
    post '/tenants' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @identity.tenants.create(json_body["tenant"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    delete '/tenants/:id' do
        begin
            response = @identity.tenants.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    # Completely removes user from tenant 
    delete '/tenants/:id/users/:user_id' do
        begin
            roles = @identity.list_roles_for_user_on_tenant(params[:id], params[:user_id]).body["roles"]
            roles.each {|role| @identity.remove_user_from_tenant(params[:id], params[:user_id], role["id"])}
            response = @identity.list_users(params[:id]).body["users"]
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    #
    # Roles
    #
    get '/roles' do
        begin
            response = @identity.list_roles.body["roles"]
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    post '/roles' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @identity.roles.create(json_body["role"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    delete '/roles/:id' do
        begin
            response = @identity.roles.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
end
