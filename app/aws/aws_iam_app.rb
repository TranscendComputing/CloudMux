require 'sinatra'
require 'fog'

class AwsIamApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
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
	get '/users' do
		filters = params[:filters]
		if(filters.nil?)
			response = @iam.users
		else
			response = @iam.users.all(filters)
		end
		[OK, response.to_json]
	end
	
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
	get '/groups' do
		filters = params[:filters]
		if(filters.nil?)
			response = @iam.list_groups.body["Groups"]
		else
			response = @iam.list_groups(filters).body["Groups"]
		end
		[OK, response.to_json]
	end

	get '/groups/:group_name/users' do
		begin
			response = @iam.get_group(params[:group_name]).body["Users"]
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
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

	post '/groups/:group_name/users/:user_id' do
		begin
			response = @iam.add_user_to_group(params[:group_name], params[:user_id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

	delete '/groups/:group_name/users/:user_id' do
		begin
			response = @iam.remove_user_from_group(params[:group_name], params[:user_id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
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
