require 'sinatra'
require 'fog'

class AwsObjectStorageApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@object_storage = Fog::Storage::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@object_storage = Fog::Storage::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @object_storage.nil?
    end

	#
	# Buckets
	#
  ##~ sapi = source2swagger.namespace("aws_object_storage")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Directories"] = {:id => "Directories", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
	get '/directories' do
		filters = params[:filters]
		if(filters.nil?)
			response = @object_storage.directories
		else
			response = @object_storage.directories.all(filters)
		end
		[OK, response.to_json]
	end
	
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
	get '/directories/:id/files' do
		begin
			response = @object_storage.directories.get(params[:id]).files
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
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
	
	delete '/directories/:id/files/:file_id' do
		begin
			response = @object_storage.delete_object(params[:id], params[:file_id]).body
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
