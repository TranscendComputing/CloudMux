require 'sinatra'
require 'fog'

class AwsBlockStorageApp < ResourceApiBase
	#
	# Volumes
	#
  ##~ sapi = source2swagger.namespace("block_storage_aws")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes/describe"
  ##~ a.description = "Manage block storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe block storage (EBS) volumes (AWS cloud)"
  ##~ op.nickname = "describe_volumes"
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "filters", :description => "Filters for instances", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of volumes returned", :code => 200
  ##~ op.errorResponses.add :reason => "Credentials not supported by cloud", :code => 400
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
				begin
					response = block_storage.volumes.create(json_body["volume"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				begin
					response = block_storage.volumes.get(json_body["volume"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				begin
					response = block_storage.attach_volume(json_body["volume"]["server_id"], json_body["volume"]["id"], json_body["volume"]["device"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				begin
					response = block_storage.detach_volume(json_body["volume"]["id"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				begin
					response = block_storage.detach_volume(json_body["volume"]["id"], {"Force"=>true})
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				begin
					response = block_storage.snapshots.create(json_body["snapshot"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				begin
					response = block_storage.snapshots.get(json_body["snapshot"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
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
				if region.nil? or region == "undefined" or region == ""
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
				end
			end
		end
	end
end
