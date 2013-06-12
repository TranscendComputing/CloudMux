require 'sinatra'
require 'fog'

class AwsBlockStorageApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@block_storage = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@block_storage = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @block_storage.nil?
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
			[BAD_REQUEST]
		else
			begin
				response = @block_storage.attach_volume(json_body["server_id"], params[:id], json_body["device"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	post '/volumes/:id/detach' do
		if(params[:id])
			[BAD_REQUEST]
		else
			begin
				response = @block_storage.detach_volume(params[:id])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	post '/volumes/:id/force_detach' do
		begin
			response = @block_storage.detach_volume(params[:id], {"Force"=>true})
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
		if(json_body.nil? || json_body["snapshot"].nil?)
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
			response = block_storage.snapshots.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
end
