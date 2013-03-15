require 'sinatra'
require 'fog'

class AwsObjectStorageApp < ResourceApiBase
	#
	# Buckets
	#
	get '/directories/describe' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = object_storage.directories
			else
				response = object_storage.directories.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/directories/create' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = object_storage.directories.create(json_body["directory"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/directories/delete' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["directory"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = object_storage.directories.get(json_body["directory"]["key"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	#
	# Files
	#
	get '/directory/files' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			directory = params[:directory]
			if(directory.nil?)
				[BAD_REQUEST]
			else
				begin
					response = object_storage.directories.get(directory).files
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	post '/directory/file/download' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			file = params[:file]
			directory = params[:directory]
			if(file.nil? || directory.nil?)
				[BAD_REQUEST]
			else
				begin
					response = object_storage.get_object(directory, file).body
					headers["Content-disposition"] = "attachment; filename=" + file
					[OK, response]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	post '/directory/file/upload' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			file = params[:file_upload]
			directory = params[:directory]
			if(file.nil? || directory.nil?)
				[BAD_REQUEST]
			else
				begin
					response = object_storage.put_object(directory, file[:filename], file[:tempfile])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/directory/file/delete' do
		object_storage = get_object_storage_interface(params[:cred_id])
		if(object_storage.nil?)
			[BAD_REQUEST]
		else
			file = params[:file]
			directory = params[:directory]
			if(file.nil? || directory.nil?)
				[BAD_REQUEST]
			else
				begin
					response = object_storage.delete_object(directory, file).body
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_object_storage_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::Storage::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
