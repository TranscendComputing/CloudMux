require 'sinatra'
require 'fog'

class AwsBlockStorageApp < ResourceApiBase
	#
	# Volumes
	#
	get '/volumes/describe' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = block_storage.volumes
			else
				response = block_storage.volumes.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/volumes/create' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
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
	
	delete '/volumes/delete' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["volume"].nil?)
				[BAD_REQUEST]
			else
				response = block_storage.volumes.get(json_body["volume"]["id"]).destroy
				[OK, response.to_json]
			end
		end
	end
	
	post '/volumes/attach' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["volume"].nil?)
				[BAD_REQUEST]
			else
				response = block_storage.attach_volume(json_body["volume"]["server_id"], json_body["volume"]["id"], json_body["volume"]["device"])
				[OK, response.to_json]
			end
		end
	end
	
	post '/volumes/detach' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["volume"].nil?)
				[BAD_REQUEST]
			else
				response = block_storage.detach_volume(json_body["volume"]["id"])
				[OK, response.to_json]
			end
		end
	end
	
	post '/volumes/force_detach' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["volume"].nil?)
				[BAD_REQUEST]
			else
				response = block_storage.detach_volume(json_body["volume"]["id"], {"Force"=>true})
				[OK, response.to_json]
			end
		end
	end
	
	#
	# Snapshots
	#
	get '/snapshots/describe' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = block_storage.snapshots
			else
				response = block_storage.snapshots.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/snapshots/create' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				response = block_storage.snapshots.create(json_body["snapshot"])
				[OK, response.to_json]
			end
		end
	end
	
	delete '/snapshots/delete' do
		block_storage = get_block_storage_interface(params[:cred_id], params[:region])
		if(block_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["snapshot"].nil?)
				[BAD_REQUEST]
			else
				response = block_storage.snapshots.get(json_body["snapshot"]["id"]).destroy
				[OK, response.to_json]
			end
		end
	end

	def get_block_storage_interface(cred_id, region)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				if region.nil? and region != "undefined" and region != ""
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
				end
			end
		end
	end
end
