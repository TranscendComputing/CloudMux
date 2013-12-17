require 'sinatra'
require 'fog'

class AwsDnsApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil? && Auth.validate(params[:cred_id],"Route 53","action")
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				@dns = Fog::DNS::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			  halt [BAD_REQUEST] if @dns.nil?
      else
        halt [NOT_FOUND, "Credentials not found."]
      end
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "Cannot access this service under current policy."
      halt [NOT_AUTHORIZED, message.to_json]
		end
  end

	#
	# Hosted Zones
	#
  ##~ sapi = source2swagger.namespace("aws_dns")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Zone"] = {:id => "Zone", :properties => {:domain => {:type => "string"}, :caller_ref => {:type => "string"}, :comment => {:type => "string"}}}
  ##~ sapi.models["Record"] = {:id => "Record", :properties => {:zone_id => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/dns/hosted_zones"
  ##~ a.description = "Manage DNS resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Zone"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe DNS Zones (AWS cloud)"
  ##~ op.nickname = "describe_dns_zones"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for zones", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of DNS zones returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/hosted_zones' do
    begin
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @dns.zones
  		else
  			response = @dns.zones.all(filters)
  		end
  		[OK, response.to_json]
    rescue => error
				handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/dns/hosted_zones"
  ##~ a.description = "Manage DNS resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Zone"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create DNS Zones (AWS cloud)"
  ##~ op.nickname = "create_dns_zones"  
  ##~ sapi.models["CreateZone"] = {:id => "CreateZone", :properties => {:domain => {:type => "string"}, :caller_ref => {:type => "string"}, :comment => {:type => "string"}}}  
  ##~ op.parameters.add :name => "hosted_zone", :description => "Hosted Zone to Create", :dataType => "CreateZone", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, DNS zones created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/dns/hosted_zones/:id"
  ##~ a.description = "Manage DNS resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Zone"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete DNS Zones (AWS cloud)"
  ##~ op.nickname = "delete_dns_zones"  
  ##~ op.parameters.add :name => "id", :description => "Zone ID to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, DNS zones deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/dns/hosted_zones/:hosted_zone_id/record_sets"
  ##~ a.description = "Manage DNS resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Record"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe DNS Records (AWS cloud)"
  ##~ op.nickname = "describe_dns_records"  
  ##~ op.parameters.add :name => ":hosted_zone_id", :description => "Hosted Zone Id", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of DNS records returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/hosted_zones/:hosted_zone_id/record_sets' do
		begin
			response = @dns.list_resource_record_sets(params[:hosted_zone_id]).body["ResourceRecordSets"]
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/dns/hosted_zones/:hosted_zone_id/record_sets/change"
  ##~ a.description = "Manage DNS resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Record"
  ##~ op.set :httpMethod => "PUT"
  ##~ op.summary = "Change DNS Records (AWS cloud)"
  ##~ op.nickname = "change_dns_records"
  ##~ op.parameters.add :name => ":hosted_zone_id", :description => "Hosted Zone Id", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
  ##~ sapi.models["Changes"] = {:id => "Changes", :properties => {:action => {:type => "string"},:name => {:type => "string"},:type => {:type => "string"},:ttl => {:type => "string"}}}
  ##~ sapi.models["ChangeRecords"] = {:id => "ChangeRecords", :properties => {:change_batch => {:type => "Array", :items => {:$ref => "Changes"}}}}  
  ##~ op.parameters.add :name => ":record_set", :description => "Record Set to change", :dataType => "ChangeRecords", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, DNS record changed", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
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
