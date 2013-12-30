require 'sinatra'
require 'fog'

class AwsObjectStorageApp < ResourceApiBase

	before do
    @service_long_name = "Simple Storage"
    @service_class = Fog::Storage::AWS
    @object_storage = can_access_service(params)
  end

	#
	# Buckets
	#
  ##~ sapi = source2swagger.namespace("aws_object_storage")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Directories"] = {:id => "Directories", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directories"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Object Storage Directories (AWS cloud)"
  ##~ op.nickname = "describe_directories"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of directories returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/directories' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @object_storage.directories
  		else
  			response = @object_storage.directories.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directories"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Object Storage Directories (AWS cloud)"
  ##~ op.nickname = "create_directories"
  ##~ sapi.models["CreateDirectory"] = {:id => "CreateDirectory", :properties => {:key => {:type => "string"}}}  
  ##~ op.parameters.add :name => "directory", :description => "Directory to Create", :dataType => "CreateDirectory", :allowMultiple => false, :required => false, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, directory created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/directories' do
		json_body = body_to_json_or_die("body" => request)
		begin
			response = @object_storage.directories.create(json_body["directory"])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directories/:id"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Object Storage Directories (AWS cloud)"
  ##~ op.nickname = "delete_directories"  
  ##~ op.parameters.add :name => "id", :description => "Directory to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, directory deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/directories/:id' do
		begin
			response = @object_storage.directories.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Files
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directories/:id/files"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Object Storage Directory Files (AWS cloud)"
  ##~ op.nickname = "describe_directory_files"  
  ##~ op.parameters.add :name => "id", :description => "Directory to get files for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of directory files returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/directories/:id/files' do
		begin
			response = @object_storage.directories.get(params[:id]).files
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directory/file/download"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Get Object Storage Directory File Download (AWS cloud)"
  ##~ op.nickname = "get_directory_files_object"  
  ##~ op.parameters.add :name => "file", :description => "File name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "directory", :description => "Directory name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, object returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/directory/file/download' do
		file = params[:file]
		directory = params[:directory]
		if(file.nil? || directory.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @object_storage.get_object(directory, file).body
				headers["Content-disposition"] = "attachment; filename=" + file
				[OK, response]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directory/file/upload"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Object Storage Directory File Upload (AWS cloud)"
  ##~ op.nickname = "upload_directory_files_object"  
  ##~ sapi.models["UploadFile"] = {:id => "UploadFile", :properties => {:filename => {:type => "string"},:tempfile => {:type => "byte"}}}
  ##~ op.parameters.add :name => ":file_upload", :description => "File Upload", :dataType => "UploadFile", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "directory", :description => "Directory name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, object uploaded", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/directory/file/upload' do
		file = params[:file_upload]
		directory = params[:directory]
		if(file.nil? || directory.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @object_storage.put_object(directory, file[:filename], file[:tempfile])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/object_storage/directories/:id/files/:file_id"
  ##~ a.description = "Manage Object Storage resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Object Storage Directory Files (AWS cloud)"
  ##~ op.nickname = "delete_directory_files"  
  ##~ op.parameters.add :name => "id", :description => "Directory to delete file for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "file_id", :description => "File ID to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, directory file deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/directories/:id/files/:file_id' do
		begin
			response = @object_storage.delete_object(params[:id], params[:file_id]).body
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
