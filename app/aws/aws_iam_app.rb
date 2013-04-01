require 'sinatra'
require 'fog'

class AwsIamApp < ResourceApiBase
	#
	# Users
	#
	get '/users/describe' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = iam.users
			else
				response = iam.users.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/users/create' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["user"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = iam.users.create(json_body["user"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/users/create_login_profile' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["user"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = iam.create_login_profile(json_body["user"]["id"], json_body["user"]["password"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	post '/users/create_access_key' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = iam.create_access_key(json_body).body["AccessKey"]
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/users/delete' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["user"].nil?)
				[BAD_REQUEST]
			else
				begin
					#Remove policies from user
					iam.list_user_policies(json_body["user"]["id"]).body["PolicyNames"].each do |t|
						iam.delete_user_policy(json_body["user"]["id"], t)
					end
					#Remove user from groups
					iam.list_groups_for_user(json_body["user"]["id"]).body["GroupsForUser"].each do |g|
						iam.remove_user_from_group(g["GroupName"], json_body["user"]["id"])
					end
					#Delete User Access Keys
					iam.list_access_keys({"UserName" => json_body["user"]["id"]}).body["AccessKeys"].each do |a|
						iam.delete_access_key(a["AccessKeyId"], {"UserName" => json_body["user"]["id"]})
					end
					#Delete Signing Certs
					iam.list_signing_certificates({"UserName" => json_body["user"]["id"]}).body["SigningCertificates"].each do |s|
						iam.delete_signing_certificate(s["CertificateId"], {"UserName" => json_body["user"]["id"]})
					end

					iam.delete_login_profile(json_body["user"]["id"])
				rescue
					#Rescue because there may not be a login, but user still needs to be deleted
				end	

				begin
					response = iam.users.get(json_body["user"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end	
			end
		end
	end
	
	#
	# Groups
	#
	get '/groups/describe' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = iam.list_groups.body["Groups"]
			else
				response = iam.list_groups(filters).body["Groups"]
			end
			[OK, response.to_json]
		end
	end

	get '/groups/users/describe' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			group_name = params[:group_name]
			if(group_name.nil?)
				[BAD_REQUEST]
			else
				response = iam.get_group(group_name).body["Users"]
			end
			[OK, response.to_json]
		end
	end
	
	put '/groups/create' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["group"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = iam.create_group(json_body["group"]["GroupName"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/groups/delete' do
		iam = get_iam_interface(params[:cred_id])
		if(iam.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["group"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = iam.delete_group(json_body["group"]["GroupName"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_iam_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::AWS::IAM.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
