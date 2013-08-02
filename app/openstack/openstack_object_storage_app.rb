require 'sinatra'
require 'fog'

class OpenstackObjectStorageApp < ResourceApiBase

	before do
        if(params[:cred_id].nil?)
            return nil
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                return nil
            else
                options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
                @object_storage = Fog::Storage.new(options)
                halt [BAD_REQUEST] if @object_storage.nil?
            end
        end
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
        begin
            response = @object_storage.directories
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
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
        json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @object_storage.directories.create(json_body["directory"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
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
        begin
			response = @object_storage.directories.get(params[:id]).files
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
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
        begin
        	directory = @object_storage.directories.get(params[:id])
			response = directory.files.get(params[:file_id]).body
			headers["Content-disposition"] = "attachment; filename=" + params[:file_id]
			[OK, response]
		rescue => error
			handle_error(error)
		end
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
		if(file.nil?)
			message = "File is required to upload."
			[BAD_REQUEST, message]
		else
			begin
				directory = @object_storage.directories.get(params[:id])
				response = directory.files.create(
					:key => file[:filename],
					:body => file[:tempfile]
				)
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
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
        begin
        	directory = @object_storage.directories.get(params[:id])
        	file = directory.files.get(params[:file_id])
        	if(file.destroy)
				[OK, directory.reload.to_json]
			else
				message = "Unable to delete file."
				[BAD_REQUEST, message]
			end
		rescue => error
			handle_error(error)
		end
	end
end
