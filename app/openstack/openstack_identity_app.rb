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
                @identity = Fog::Identity.new(options)
                ## TEMP HACK UNTIL CORRECTY IDENTITY URL IS RESOLVED
                ## Only required when using Essex, Folsom endpoints (service catalog) is 
                ## setup correctly
                if @identity.credentials[:openstack_management_url].include?("localhost")
                    management_url = options["openstack_auth_url"].gsub("/tokens", "")
                    @identity = Fog::Identity.new(options.merge({:openstack_management_url => management_url}))
                end
                halt [BAD_REQUEST] if @identity.nil?
            end
        end
    end

	#
	# Users
	#

	get '/users' do
        if(params[:tenant_id].nil?)
            response = @identity.list_users.body["users"]
        else
            response = @identity.list_users(params[:tenant_id]).body["users"]
        end
        [OK, response.to_json]
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
        filters = params[:filters]
        if(filters.nil?)
            response = @identity.tenants
        else
            response = @identity.tenants.all(filters)
        end
        [OK, response.to_json]
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

    get '/tenants/:id/users/:user_id/roles' do
        begin
            user_roles = @identity.list_roles_for_user_on_tenant(params[:tenant_id], params[:id]).body["roles"]
            availabilty_roles = []
            user_roles.each do |role|
                availabile_roles << @identity.roles.get(role["id"])
            end
            response = {:available_roles => available_roles, :roles => user_roles}
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    post '/tenants/:id/users/:user_id/roles/:role_id' do
        begin
            response = @identity.add_user_to_tenant(params[:id], params[:user_id], params[:role_id]).body
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    delete '/tenants/:id/users/:user_id/roles' do
        begin
            user_roles = @identity.list_roles_for_user_on_tenant(params[:id], params[:user_id]).body["roles"]
            user_roles.each do |role|
                @identity.delete_user_role(params[:id], params[:user_id], role["id"])
            end
            [OK]
        rescue => error
            handle_error(error)
        end
    end

    delete '/tenants/:id/users/:user_id/roles/:role_id' do
        begin
            response = @identity.delete_user_role(params[:id], params[:user_id], params[:role_id])
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
            response = @identity.roles
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
