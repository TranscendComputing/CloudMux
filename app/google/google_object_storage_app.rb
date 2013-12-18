require 'sinatra'
require 'fog'
require 'debugger'

class GoogleObjectStorageApp < ResourceApiBase

    before do
        cred_id = params[:cred_id]
        if ! cred_id.nil?
            cloud_cred = get_creds(cred_id)
            if ! cloud_cred.nil?
                @object_storage = Fog::Storage::Google.new({
                  :google_storage_access_key_id     => cloud_cred.cloud_attributes['google_storage_access_key_id'],
                  :google_storage_secret_access_key => cloud_cred.cloud_attributes['google_storage_secret_access_key']
                })
            end
        end
        halt [BAD_REQUEST] if @object_storage.nil?
    end

	#
	# Buckets
	#

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

    before %r{/directories/([\w]+).*} do |id|
        @dir = @object_storage.directories.get(id)
        if(@dir.nil?)
            halt NOT_FOUND
        end
    end

	delete '/directories/:id' do
		begin
			response = @dir.destroy
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
			response = @dir.files
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

	post '/directory/file/download' do
		file = params[:file]
		directory = params[:directory]
        options = {};
		if(file.nil? || directory.nil?)
			[BAD_REQUEST]
		else
			begin
				#response = @object_storage.get_object(directory, file, options).body
                response = @object_storage.directories.get(directory).files.get(file)
				headers["Content-disposition"] = "attachment; filename=" + file
				[OK, response.to_json]
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
