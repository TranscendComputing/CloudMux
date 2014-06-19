require 'sinatra'
require 'fog'

class OpenstackObjectStorageApp < ResourceApiBase

  before do
    params["provider"] = "openstack"
    @service_long_name = "Object Storage"
    @service_class = Fog::Storage
    @object_storage = can_access_service(params)
  end

  #
  # Buckets
  #
  ##~ sapi = source2swagger.namespace("openstack_object_storage")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Directory"] = {:id => "Directory", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Object Storage Directories (Openstack cloud)"
  ##~ op.nickname = "describe_directories"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of directories returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/directories' do
    response = params[:filters].nil? ?
      @object_storage.directories :
      @object_storage.directories.all(params[:filters])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Object Storage Directories (Openstack cloud)"
  ##~ op.nickname = "create_directories"
  ##~ sapi.models["CreateDirectory"] = {:id => "CreateDirectory", :properties => {:key => {:type => "string"}}}  
  ##~ op.parameters.add :name => "directory", :description => "Directory to Create", :dataType => "CreateDirectory", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, directory created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/directories' do
    json_body = body_to_json_or_die("body" => request)
    response = @object_storage.directories.create(json_body["directory"])
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories/:id"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Object Storage Directories (Openstack cloud)"
  ##~ op.nickname = "delete_directories"  
  ##~ op.parameters.add :name => "id", :description => "Directory to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, directory deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/directories/:id' do
    response = @object_storage.directories.get(params[:id]).destroy
    [OK, response.to_json]
  end
  
  #
  # Files
  #
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories/:id/files"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Object Storage Directory Files (Openstack cloud)"
  ##~ op.nickname = "describe_directory_files"  
  ##~ op.parameters.add :name => "id", :description => "Directory to get files for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of directory files returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/directories/:id/files' do
    response = @object_storage.directories.get(params[:id]).files
    [OK, response.to_json]
  end
  
  # Download file
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories/:id/files/:file_id"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Get Object Storage Directory File Download (Openstack cloud)"
  ##~ op.nickname = "get_directory_files_object"  
  ##~ op.parameters.add :name => "file_id", :description => "File name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "id", :description => "Directory name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, object returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/directories/:id/files/:file_id' do
    file = params[:file_id]
    container = params[:id]
    halt [BAD_REQUEST] if file.nil? or container.nil?

    directory = @object_storage.directories.get(container)
    response = directory.files.get(file).body
    headers["Content-disposition"] = "attachment; filename=" + file
    [OK, response]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories/:id/files"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Object Storage Directory File Upload (Openstack cloud)"
  ##~ op.nickname = "upload_directory_files_object"  
  ##~ sapi.models["UploadFile"] = {:id => "UploadFile", :properties => {:filename => {:type => "string"},:tempfile => {:type => "byte"}}}
  ##~ op.parameters.add :name => ":file_upload", :description => "File Upload", :dataType => "UploadFile", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "id", :description => "Directory name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, object uploaded", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/directories/:id/files' do
    file = params[:file_upload]
    halt [BAD_REQUEST, "File is required to upload."] if file.nil?

    directory = @object_storage.directories.get(params[:id])
    response = directory.files.create(
      :key  => file[:filename],
      :body => file[:tempfile]
    )
    [OK, response.to_json]
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/object_storage/directories/:id/files/:file_id"
  ##~ a.description = "Manage Object Storage resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Object Storage Directory Files (Openstack cloud)"
  ##~ op.nickname = "delete_directory_files"  
  ##~ op.parameters.add :name => "id", :description => "Directory to delete file for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "file_id", :description => "File ID to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, directory file deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/directories/:id/files/:file_id' do
    directory = @object_storage.directories.get(params[:id])
    file = directory.files.get(params[:file_id])
    halt [OK, directory.reload.to_json] if file.destroy
    [BAD_REQUEST, "Unable to delete file."]
  end
end
