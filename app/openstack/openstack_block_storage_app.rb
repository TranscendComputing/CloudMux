require 'sinatra'
require 'fog'

class OpenstackBlockStorageApp < ResourceApiBase

	before do
        if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
                @block_storage = Fog::Compute.new(options)
                halt [BAD_REQUEST] if @block_storage.nil?
            end
        end
    end
	
	#
	# Volumes
	#
	get '/volumes' do
		filters = params[:filters]
		if(filters.nil?)
			response = @block_storage.volumes
		else
			response = @block_storage.volumes.all(filters)
		end
		[OK, response.to_json]
	end
	
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
	
	delete '/volumes/:id' do
		begin
			response = @block_storage.volumes.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	post '/volumes/:id/attach' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["server_id"].nil? || json_body["device"].nil?)
			response = "server_id and device are required request parameters."
			[BAD_REQUEST, response]
		else
			begin
				response = @block_storage.attach_volume(params[:id], json_body["server_id"], json_body["device"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
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
	get '/snapshots' do
		filters = params[:filters]
		if(filters.nil?)
			response = @block_storage.snapshots
		else
			response = @block_storage.snapshots.all(filters)
		end
		[OK, response.to_json]
	end
	
	post '/snapshots' do
		json_body = body_to_json(request)
		if(json_body.nil?)
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
	
	delete '/snapshots/:id' do
		begin
			response = @block_storage.snapshots.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
