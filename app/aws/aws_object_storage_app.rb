require 'sinatra'
require 'fog'

class AwsObjectStorageApp < ResourceApiBase
	#
	# Buckets
	#
	post '/directories/describe' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				response = object_storage.directories
			else
				filters = json_body["filters"]
				response = object_storage.directories.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/directories/create' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				response = object_storage.directories.create(json_body["directory"])
				[OK, response.to_json]
			end
		end
	end

	def get_object_storage_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = Account.find_cloud_account(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::Storage::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
