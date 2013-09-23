require 'sinatra'
require 'fog'

class AwsIamApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil? && Auth.validate(params[:cred_id],"IAM","action")
            #halt [BAD_REQUEST] if ! Auth.validate(params[:cred_id],"IAM","action")
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				@iam = Fog::AWS::IAM.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
		halt [BAD_REQUEST] if @iam.nil?
    end

	#
	# Users
	#
  ##~ sapi = source2swagger.namespace("aws_iam")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["User"] = {:id => "User", :properties => {:Arn => {:type => "string"}, :UserId => {:type => "string"}, :UserName => {:type => "string"}, :Path => {:type => "string"}}}
  ##~ sapi.models["UserList"] = {:id => "UserList", :properties => {:Users => {:type => "Array", :items => {:$ref => "User"}}}}
  ##~ sapi.models["Group"] = {:id => "Group", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  ##~ sapi.models["GroupList"] = {:id => "GroupList", :properties => {:Users => {:type => "Array", :items => {:$ref => "Group"}}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/users"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "UserList"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe IAM Users (AWS cloud)"
  ##~ op.nickname = "describe_iam_users"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of IAM users returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/users' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @iam.users
  		else
  			response = @iam.users.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/users"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create IAM Users (AWS cloud)"
  ##~ op.nickname = "create_iam_users"  
  ##~ sapi.models["CreateUser"] = {:id => "CreateUser", :properties => {:user_name => {:type => "string"}, :path => {:type => "string"}}}
  ##~ op.parameters.add :name => "user", :description => "User definition", :dataType => "CreateUser", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of IAM users returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/users' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["user"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @iam.users.create(json_body["user"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/users/login_profile"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create IAM User Login Profile (AWS cloud)"
  ##~ op.nickname = "create_iam_users_login_profile"  
  ##~ sapi.models["CreateLogin"] = {:id => "CreateLogin", :properties => {:id => {:type => "string"}, :password => {:type => "string"}}}
  ##~ op.parameters.add :name => "user", :description => "User for profile", :dataType => "CreateLogin", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, IAM user profile created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/users/login_profile' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["user"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @iam.create_login_profile(json_body["user"]["id"], json_body["user"]["password"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/users/access_key"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create IAM User Access Key (AWS cloud)"
  ##~ op.nickname = "create_iam_users_access_key"  
  ##~ sapi.models["CreateAccessKey"] = {:id => "CreateAccessKey", :properties => {:UserName => {:type => "string"}}}
  ##~ op.parameters.add :name => "options", :description => "User AccessKey options", :dataType => "CreateAccessKey", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, IAM Access Key created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/users/access_key' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @iam.create_access_key(json_body).body["AccessKey"]
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/users/:id"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete IAM Users (AWS cloud)"
  ##~ op.nickname = "delete_iam_users"  
  ##~ op.parameters.add :name => "id", :description => "User id to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, IAM User deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/users/:id' do
		begin
			#Remove policies from user
			@iam.list_user_policies(params[:id]).body["PolicyNames"].each do |t|
				@iam.delete_user_policy(params[:id], t)
			end
			#Remove user from groups
			@iam.list_groups_for_user(params[:id]).body["GroupsForUser"].each do |g|
				@iam.remove_user_from_group(g["GroupName"], params[:id])
			end
			#Delete User Access Keys
			@iam.list_access_keys({"UserName" => params[:id]}).body["AccessKeys"].each do |a|
				@iam.delete_access_key(a["AccessKeyId"], {"UserName" => params[:id]})
			end
			#Delete Signing Certs
			@iam.list_signing_certificates({"UserName" => params[:id]}).body["SigningCertificates"].each do |s|
				@iam.delete_signing_certificate(s["CertificateId"], {"UserName" => params[:id]})
			end

			@iam.delete_login_profile(params[:id])
		rescue
			#Rescue because there may not be a login, but user still needs to be deleted
		end	

		begin
			response = @iam.users.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Groups
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/groups"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Group"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe IAM Groups (AWS cloud)"
  ##~ op.nickname = "describe_iam_groups"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for groups", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of IAM groups returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/groups' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @iam.list_groups.body["Groups"]
  		else
  			response = @iam.list_groups(filters).body["Groups"]
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/groups/:group_name/users"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "User"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe IAM Group Users (AWS cloud)"
  ##~ op.nickname = "describe_iam_group_users"  
  ##~ op.parameters.add :name => "group_name", :description => "Group Name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of IAM group users returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/groups/:group_name/users' do
		begin
			response = @iam.get_group(params[:group_name]).body["Users"]
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/groups"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Group"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create IAM Group (AWS cloud)"
  ##~ op.nickname = "create_iam_group"  
  ##~ sapi.models["CreateGroup"] = {:id => "CreateGroup", :properties => {:GroupName => {:type => "string"}}}
  ##~ op.parameters.add :name => "group", :description => "Group to Create", :dataType => "CreateGroup", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, IAM group created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/groups' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["group"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @iam.create_group(json_body["group"]["GroupName"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/groups/:group_name/users/:user_id"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Group"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Add user to IAM Group (AWS cloud)"
  ##~ op.nickname = "add_user_iam_group"  
  ##~ op.parameters.add :name => "group_name", :description => "Group Name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "user_id", :description => "User ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, IAM group user added", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/groups/:group_name/users/:user_id' do
		begin
			response = @iam.add_user_to_group(params[:group_name], params[:user_id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/groups/:group_name/users/:user_id"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Group"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Remove user from IAM Group (AWS cloud)"
  ##~ op.nickname = "remove_user_iam_group"  
  ##~ op.parameters.add :name => "group_name", :description => "Group Name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "user_id", :description => "User ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, IAM group user removed", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/groups/:group_name/users/:user_id' do
		begin
			response = @iam.remove_user_from_group(params[:group_name], params[:user_id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/iam/groups/:group_name/users/:user_id"
  ##~ a.description = "Manage IAM resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Group"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Remove IAM Group (AWS cloud)"
  ##~ op.nickname = "remove_iam_group"  
  ##~ op.parameters.add :name => "group_name", :description => "Group Name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, IAM group removed", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/groups/:group_name' do
		begin
			# remove all group policies
			policies = @iam.list_group_policies(params[:group_name]).body["PolicyNames"]
			policies.each {|policy| @iam.delete_group_policy(params[:group_name], policy)}
			# remove all group users
			users = @iam.get_group(params[:group_name]).body["Users"]
			users.each {|user| @iam.remove_user_from_group(params[:group_name], user["UserName"])}
			#delete the group
			response = @iam.delete_group(params[:group_name])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
