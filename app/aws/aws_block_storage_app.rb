require 'sinatra'
require 'fog'

class AwsBlockStorageApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@block_storage = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@block_storage = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @block_storage.nil?
    end

	#
	# Volumes
	#
  ##~ sapi = source2swagger.namespace("block_storage_aws")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Volume"] = {:id => "Volume", :properties => {:availability_zone => {:type => "string"}, :size => {:type => "string"}, :snapshot_id => {:type => "string"}, :iops => {:type => "string"}, :key => {:type => "string"}, :resource_id => {:type => "string"}, :value => {:type => "string"}}}
  ##~ sapi.models["Snapshot"] = {:id => "Snapshot", :properties => {:volume_id => {:type => "string"},:description => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "describe_block_storage_volumes"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for volumes", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of volumes returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	get '/volumes' do
		filters = params[:filters]
		if(filters.nil?)
			response = @block_storage.volumes
		else
			response = @block_storage.volumes.all(filters)
		end
		[OK, response.to_json]
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "create_block_storage_volumes"  
  ##~ op.parameters.add :name => "volume", :description => "Volume to create", :dataType => "Volume", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, volume created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/volumes' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @block_storage.volumes.create(json_body["volume"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes/:id"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "delete_block_storage_volumes"  
  ##~ op.parameters.add :name => "id", :description => "Volume id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, volume deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	delete '/volumes/:id' do
		begin
			response = @block_storage.volumes.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes/:id/attach"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Attach Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "attach_block_storage_volumes"
  ##~ op.parameters.add :name => "id", :description => "Volume ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
  ##~ op.parameters.add :name => "server_id", :description => "Server ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.parameters.add :name => "device", :description => "Device", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, volume attached", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/volumes/:id/attach' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["server_id"].nil? || json_body["device"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @block_storage.attach_volume(json_body["server_id"], params[:id], json_body["device"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes/:id/detach"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Detach Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "detach_block_storage_volumes"  
  ##~ op.parameters.add :name => "id", :description => "volume id", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, volume attached", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/volumes/:id/detach' do
		if(params[:id])
			[BAD_REQUEST]
		else
			begin
				response = @block_storage.detach_volume(params[:id])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes/:id/force_detach"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Force Detach Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "force_detach_block_storage_volumes"  
  ##~ op.parameters.add :name => "id", :description => "volume id", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, volume attached", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/volumes/:id/force_detach' do
		begin
			response = @block_storage.detach_volume(params[:id], {"Force"=>true})
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Snapshots
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/snapshots"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Snapshot"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Block Storage Snapshots (AWS cloud)"
  ##~ op.nickname = "describe_block_storage_snapshots"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for snapshots", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of Snapshots returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	get '/snapshots' do
		filters = params[:filters]
		if(filters.nil?)
			response = @block_storage.snapshots
		else
			response = @block_storage.snapshots.all(filters)
		end
		[OK, response.to_json]
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/snapshots"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Snapshot"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Block Storage Snapshots (AWS cloud)"
  ##~ op.nickname = "create_block_storage_snapshots"  
  ##~ op.parameters.add :name => "snapshot", :description => "Snapshot to create", :dataType => "Snapshot", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, Snapshot created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/snapshots' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["snapshot"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @block_storage.snapshots.create(json_body["snapshot"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/snapshots/:id"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Snapshot"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Block Storage Snapshots (AWS cloud)"
  ##~ op.nickname = "delete_block_storage_snapshots"  
  ##~ op.parameters.add :name => "id", :description => "Snapshot id to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, Snapshot deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	delete '/snapshots/:id' do
		begin
			response = block_storage.snapshots.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
