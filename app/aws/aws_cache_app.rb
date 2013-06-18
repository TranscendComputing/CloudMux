require 'sinatra'
require 'fog'

class AwsCacheApp < ResourceApiBase
	
	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@elasticache = Fog::AWS::Elasticache.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@elasticache = Fog::AWS::Elasticache.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @elasticache.nil?
    end
    
	#
	# Clusters
	#
	get '/clusters' do
		filters = params[:filters]
		if(filters.nil?)
			response = @elasticache.clusters
		else
			response = @elasticache.clusters.all(filters)
		end
		[OK, response.to_json]
	end
  
	post '/clusters' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @elasticache.clusters.create(json_body["cluster"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
	delete '/clusters/:id' do
		begin
			response = @elasticache.clusters.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Additional Methods
  #
	get '/parameter_groups' do
		filters = params[:filters]
		if(filters.nil?)
			response = @elasticache.parameter_groups
		else
			response = @elasticache.parameter_groups.all(filters)
		end
		[OK, response.to_json]
	end

	get '/security_groups' do
		filters = params[:filters]
		if(filters.nil?)
			response = @elasticache.security_groups
		else
			response = @elasticache.security_groups.all(filters)
		end
		[OK, response.to_json]
	end
  
	post '/clusters/modify/:id' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
        #require "debugger"
        #debugger
				response = @elasticache.modify_cache_cluster(params[:id],json_body["options"].symbolize_keys!)
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
end
