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
	get '/directories' do
        begin
            response = @object_storage.directories
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
	
	# Download file
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
