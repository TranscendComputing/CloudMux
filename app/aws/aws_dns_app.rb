require 'sinatra'
require 'fog'

class AwsDnsApp < ResourceApiBase
	#
	# Hosted Zones
	#
	get '/hosted_zones/describe' do
		dns = get_dns_interface(params[:cred_id])
		if(dns.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				response = dns.zones
			else
				response = dns.zones.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/hosted_zones/create' do
		dns = get_dns_interface(params[:cred_id])
		if(dns.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					response = dns.zones.create(json_body["hosted_zone"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/hosted_zones/delete' do
		dns = get_dns_interface(params[:cred_id])
		if(dns.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["hosted_zone"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = dns.zones.get(json_body["hosted_zone"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	#
	# Record Sets
	#
	get '/record_sets/describe' do
		dns = get_dns_interface(params[:cred_id])
		if(dns.nil?)
			[BAD_REQUEST]
		else
			hosted_zone_id = params[:hosted_zone_id]
			if(hosted_zone_id.nil?)
				[BAD_REQUEST]
			else
				begin
					response = dns.list_resource_record_sets(hosted_zone_id).body["ResourceRecordSets"]
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	put '/record_sets/change' do
		dns = get_dns_interface(params[:cred_id])
		if(dns.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				begin
					#must symbolize keys
					change_batch_symbolized = []
					json_body["record_set"]["change_batch"].each {|change| change_batch_symbolized<<change.symbolize_keys}
					if(json_body["record_set"]["options"].nil?)
						response = dns.change_resource_record_sets(json_body["record_set"]["hosted_zone_id"], change_batch_symbolized)
					else
						response = dns.change_resource_record_sets(json_body["record_set"]["hosted_zone_id"], change_batch_symbolized, json_body["record_set"]["options"])
					end
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end
	
	delete '/record_sets/delete' do
		dns = get_dns_interface(params[:cred_id])
		if(dns.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["hosted_zone"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = dns.zones.get(json_body["hosted_zone"]["id"]).destroy
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_dns_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::DNS::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
