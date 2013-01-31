require 'sinatra'
require 'fog'

class AwsBlockStorageApp < ResourceApiBase
	#
	# Volumes
	#
	post '/volumes/describe' do
		block_storage = get_block_storage_interface(params[:cred_id])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				response = block_storage.volumes
			else
				filters = json_body["filters"]
				response = block_storage.volumes.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/volumes/create' do
		block_storage = get_block_storage_interface(params[:cred_id])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				response = block_storage.volumes.create(json_body["volume"])
				[OK, response.to_json]
			end
		end
	end

	def get_block_storage_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = Account.find_cloud_account(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
