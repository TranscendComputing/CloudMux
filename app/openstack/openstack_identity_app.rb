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
  ##~ sapi = source2swagger.namespace("openstack_identity")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["User"] = {:id => "User", :properties => {:name => {:type => "string"}, :tenant_id => {:type => "string"}, :password => {:type => "string"}, :email => {:type => "string"}}}
  ##~ sapi.models["Tenant"] = {:id => "User", :properties => {:name => {:type => "string"}}}
  ##~ sapi.models["Role"] = {:id => "User", :properties => {:name => {:type => "string"}}}

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/users"
  ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Users (Openstack cloud)"
  ##~ op.nickname = "describe_users"
  ##~ op.parameters.add :name => ":tenant_id", :description => "Tenant ID to list users for", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"  
  ##~ op.errorResponses.add :reason => "Success, list of users returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/users' do
        begin
            if(params[:tenant_id].nil?)
                response = @identity.list_users.body["users"]
            else
                response = @identity.list_users(params[:tenant_id]).body["users"]
            end
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/users"
  ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create User (Openstack cloud)"
  ##~ op.nickname = "create_user"  
  ##~ op.parameters.add :name => "user", :description => "User to create", :dataType => "User", :allowMultiple => false, :required => true, :paramType => "body"  
  ##~ op.errorResponses.add :reason => "Success, users created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/users/:id"
  ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete User (Openstack cloud)"
  ##~ op.nickname = "delete_user"  
  ##~ op.parameters.add :name => "id", :description => "User id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
  ##~ op.errorResponses.add :reason => "Success, user deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants"
  ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Tenant"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Tenants (Openstack cloud)"
  ##~ op.nickname = "describe_tenants"
  ##~ op.parameters.add :name => "filters", :description => "Filters for tenants", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query" 
  ##~ op.errorResponses.add :reason => "Success, list of tenants returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/tenants' do
        filters = params[:filters]
        if(filters.nil?)
            response = @identity.tenants
        else
            response = @identity.tenants.all(filters)
        end
        [OK, response.to_json]
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants"
  ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Tenant"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Tenant (Openstack cloud)"
  ##~ op.nickname = "create_tenant"  
  ##~ op.parameters.add :name => "tenant", :description => "Tenant to create", :dataType => "Tenant", :allowMultiple => false, :required => true, :paramType => "body"  
  ##~ op.errorResponses.add :reason => "Success, tenants created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
    
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants/:id"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Tenant"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Tenant (Openstack cloud)"
    ##~ op.nickname = "delete_tenant"  
    ##~ op.parameters.add :name => "id", :description => "Tenant id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, user deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/tenants/:id' do
        begin
            response = @identity.tenants.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants/:id/users/:user_id/roles"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe User Roles (Openstack cloud)"
    ##~ op.nickname = "describe_user_roles"
    ##~ op.parameters.add :name => ":tenant_id", :description => "Tenant ID to list roles for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => ":id", :description => "User ID to list roles for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, list of roles returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants/:id/users/:user_id/roles/:role_id"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Add user role to Tenant (Openstack cloud)"
    ##~ op.nickname = "create_user_role"  
    ##~ op.parameters.add :name => ":id", :description => "Tenant ID to add role to", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.parameters.add :name => ":user_id", :description => "User ID to add role for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.parameters.add :name => ":role_id", :description => "Role ID to add", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, role added", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/tenants/:id/users/:user_id/roles/:role_id' do
        begin
            response = @identity.add_user_to_tenant(params[:id], params[:user_id], params[:role_id]).body
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants/:id/users/:user_id/roles"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Remove User Roles (Openstack cloud)"
    ##~ op.nickname = "remove_user_rolls"  
    ##~ op.parameters.add :name => ":id", :description => "Tenant ID to remove roles from", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.parameters.add :name => ":user_id", :description => "User ID to remove roles from", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, user roles removed", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/tenants/:id/users/:user_id/roles/:role_id"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Remove User Role (Openstack cloud)"
    ##~ op.nickname = "remove_user_roll"  
    ##~ op.parameters.add :name => ":id", :description => "Tenant ID to remove role from", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.parameters.add :name => ":user_id", :description => "User ID to remove role from", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.parameters.add :name => ":role_id", :description => "Role ID to remove", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, user role removed", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/roles"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Roles (Openstack cloud)"
    ##~ op.nickname = "describe_rolls"
    ##~ op.parameters.add :name => "filters", :description => "Filters for tenants", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query" 
    ##~ op.errorResponses.add :reason => "Success, list of roles returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    get '/roles' do
        begin
            response = @identity.roles
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/roles"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create Role (Openstack cloud)"
    ##~ op.nickname = "create_role"  
    ##~ op.parameters.add :name => "role", :description => "Role to create", :dataType => "Role", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, role created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/identity/roles/:id"
    ##~ a.description = "Manage Identity resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Role"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Role (Openstack cloud)"
    ##~ op.nickname = "delete_role"  
    ##~ op.parameters.add :name => "id", :description => "Role id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, role deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/roles/:id' do
        begin
            response = @identity.roles.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
end
