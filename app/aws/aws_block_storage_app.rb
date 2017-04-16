require 'sinatra'
require 'fog'

class AwsBlockStorageApp < ResourceApiBase

  before do
    params["provider"] = "aws"
    @service_long_name = "Elastic Block Storage"
    @service_class = Fog::Compute::AWS
    @block_storage = can_access_service(params)
  end

  #
  # Volumes
  #
  ##~ sapi = source2swagger.namespace("aws_block_storage")
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/volumes' do
    begin
      filters = params[:filters]
      response = filters.nil? ?
        @block_storage.volumes :
        @block_storage.volumes.all(filters)
      [OK, response.to_json]
    rescue => error
      pre_handle_error(@block_storage, error)
    end
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/block_storage/volumes"
  ##~ a.description = "Manage Block Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Volume"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Block Storage Volumes (AWS cloud)"
  ##~ op.nickname = "create_block_storage_volumes"  
  ##~ sapi.models["CreateVolume"] = {:id => "CreateVolume", :properties => {:availability_zone => {:type => "string"}, :size => {:type => "int"}, :snapshot_id => {:type => "string"}, :type => {:type => "string"}, :iops => {:type => "int"}}}  
  ##~ op.parameters.add :name => "volume", :description => "Volume to create", :dataType => "CreateVolume", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, volume created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/volumes' do
    json_body = body_to_json_or_die("body" => request)
    response = @block_storage.volumes.create(json_body["volume"])
    Auth.validate(
      params[:cred_id],
      "Elastic Block Storage",
      "create_default_alarms",
      {
        :params => params,
        :resource_id => response.id,
        :namespace => "AWS/EBS"
      }
    )
    [OK, response.to_json]
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/volumes/:id' do
    response = @block_storage.volumes.get(params[:id]).destroy
    [OK, response.to_json]
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/volumes/:id/attach' do
    json_body = body_to_json_or_die(
      "body" => request,
      "args" => ["server_id","device"]
    )

    response = @block_storage.attach_volume(
      json_body["server_id"],
      params[:id],
      json_body["device"]
    )

    [OK, response.to_json]
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/volumes/:id/detach' do
    halt [BAD_REQUEST] unless params[:id]
    response = @block_storage.detach_volume(params[:id])
    [OK, response.to_json]
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/volumes/:id/force_detach' do
    response = @block_storage.detach_volume(params[:id], {"Force"=>true})
    [OK, response.to_json]
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/snapshots' do
    filters = params[:filters]
    response = filters.nil? ?
      @block_storage.snapshots :
      @block_storage.snapshots.all(filters)
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
  ##~ sapi.models["CreateSnapshot"] = {:id => "CreateSnapshot", :properties => {:volume_id => {:type => "string"}, :description => {:type => "string"}}}  
  ##~ op.parameters.add :name => "snapshot", :description => "Snapshot to create", :dataType => "CreateSnapshot", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, Snapshot created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/snapshots' do
    json_body = body_to_json_or_die("body" => request, "args" => ["snapshot"])
    response = @block_storage.snapshots.create(json_body["snapshot"])
    [OK, response.to_json]
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
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/snapshots/:id' do
    response = block_storage.snapshots.get(params[:id]).destroy
    [OK, response.to_json]
  end
end
