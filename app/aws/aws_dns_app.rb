require 'sinatra'
require 'fog'

class AwsDnsApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				@dns = Fog::DNS::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
		halt [BAD_REQUEST] if @dns.nil?
    end

	#
	# Hosted Zones
	#
	get '/hosted_zones' do
		filters = params[:filters]
		if(filters.nil?)
			response = @dns.zones
		else
			response = @dns.zones.all(filters)
		end
		[OK, response.to_json]
	end
	
	post '/hosted_zones' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @dns.zones.create(json_body["hosted_zone"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	delete '/hosted_zones/:id' do
		begin
			response = @dns.zones.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

	#
	# Record Sets
	#
	get '/hosted_zones/:hosted_zone_id/record_sets' do
		begin
			response = @dns.list_resource_record_sets(params[:hosted_zone_id]).body["ResourceRecordSets"]
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	put '/hosted_zones/:hosted_zone_id/record_sets/change' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				#must symbolize keys
				change_batch_symbolized = []
				json_body["record_set"]["change_batch"].each {|change| change_batch_symbolized<<change.symbolize_keys}
				if(json_body["record_set"]["options"].nil?)
					response = @dns.change_resource_record_sets(params[:hosted_zone_id], change_batch_symbolized)
				else
					response = @dns.change_resource_record_sets(params[:hosted_zone_id], change_batch_symbolized, json_body["record_set"]["options"])
				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
end
