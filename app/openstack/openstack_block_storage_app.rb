require 'sinatra'
require 'fog'

class OpenstackBlockStorageApp < ResourceApiBase

	before do
    params["provider"] = "openstack"
    @service_long_name = "Block Storage"
    @service_class = Fog::Compute
    @block_storage = can_access_service(params)
  end
	
	#
	# Volumes
	#
  ##~ sapi = source2swagger.namespace("openstack_block_storage")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Volume"] = {:id => "Volume", :properties => {:availability_zone => {:type => "string"}, :size => {:type => "string"}, :snapshot_id => {:type => "string"}, :iops => {:type => "string"}, :key => {:type => "string"}, :resource_id => {:type => "string"}, :value => {:type => "string"}}}
  ##~ sapi.models["Snapshot"] = {:id => "Snapshot", :properties => {:volume_id => {:type => "string"},:description => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/volumes"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Block Storage Volumes (Openstack cloud)"
  ##~ op.nickname = "describe_block_storage_volumes"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for volumes", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of volumes returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/volumes' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @block_storage.volumes
  		else
  			response = @block_storage.volumes.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/volumes"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Block Storage Volumes (Openstack cloud)"
  ##~ op.nickname = "create_block_storage_volumes"
  ##~ sapi.models["CreateVolume"] = {:id => "CreateVolume", :properties => {:availability_zone => {:type => "string"}, :size => {:type => "int"}, :snapshot_id => {:type => "string"}, :type => {:type => "string"}, :iops => {:type => "int"}}}  
  ##~ op.parameters.add :name => "volume", :description => "Volume to create", :dataType => "CreateVolume", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, volume created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/volumes' do
    json_body = body_to_json_or_die("body" => request)
    user_id = Auth.find_account(params[:cred_id]).id
    can_create_instance("cred_id" => params[:cred_id], "action" => "create_block_storage", "options" => {:instance_count => UserResource.count_resources(user_id,"Block Storage"), :volume_size => json_body["volume"]["size"]} )
		begin
			response = @block_storage.volumes.create(json_body["volume"])
      UserResource.create!(account_id: user_id, resource_id: response.id, resource_type: "Block Storage", operation: "create", size: json_body["volume"]["size"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/volumes/:id"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Block Storage Volumes (Openstack cloud)"
  ##~ op.nickname = "delete_block_storage_volumes"  
  ##~ op.parameters.add :name => "id", :description => "Volume id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, volume deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/volumes/:id' do
		begin
			response = @block_storage.volumes.get(params[:id]).destroy
      UserResource.delete_resource(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/volumes/:id/attach"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Attach Block Storage Volumes (Openstack cloud)"
  ##~ op.nickname = "attach_block_storage_volumes"
  ##~ op.parameters.add :name => "id", :description => "Volume ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
  ##~ op.parameters.add :name => "server_id", :description => "Server ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.parameters.add :name => "device", :description => "Device", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, volume attached", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/volumes/:id/attach' do
    json_body = body_to_json_or_die("body" => request, "args" => ["server_id","device"])
		begin
			response = @block_storage.attach_volume(params[:id], json_body["server_id"], json_body["device"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/volumes/:id/detach/:server_id"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Detach Block Storage Volumes (Openstack cloud)"
  ##~ op.nickname = "detach_block_storage_volumes"  
  ##~ op.parameters.add :name => "id", :description => "volume id", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "server_id", :description => "server id", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, volume attached", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/volumes/:id/detach/:server_id' do
		begin
			response = @block_storage.detach_volume(params[:server_id], params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Snapshots
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/snapshots"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Snapshot"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Block Storage Snapshots (Openstack cloud)"
  ##~ op.nickname = "describe_block_storage_snapshots"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for snapshots", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of Snapshots returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/snapshots"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Snapshot"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Block Storage Snapshots (Openstack cloud)"
  ##~ op.nickname = "create_block_storage_snapshots"
  ##~ sapi.models["CreateSnapshot"] = {:id => "CreateSnapshot", :properties => {:volume_id => {:type => "string"}, :description => {:type => "string"}}}  
  ##~ op.parameters.add :name => "snapshot", :description => "Snapshot to create", :dataType => "CreateSnapshot", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, Snapshot created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/snapshots' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @block_storage.snapshots.create(json_body["snapshot"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/block_storage/snapshots/:id"
  ##~ a.description = "Manage Block Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Snapshot"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Block Storage Snapshots (Openstack cloud)"
  ##~ op.nickname = "delete_block_storage_snapshots"  
  ##~ op.parameters.add :name => "id", :description => "Snapshot id to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, Snapshot deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/snapshots/:id' do
		begin
			response = @block_storage.snapshots.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
