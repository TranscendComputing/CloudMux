require 'sinatra'
require 'fog'

class TopStackRdsApp < ResourceApiBase

	before do
		if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                begin
                    # Find RDS service endpoint
                    endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"RDS"}).first
                    halt [BAD_REQUEST] if endpoint.nil?
                    fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                    fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                    @rds = Fog::AWS::RDS.new(fog_options)
                    halt [BAD_REQUEST] if @rds.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# Databases
	#
	get '/databases' do
		filters = params[:filters]
		if(filters.nil?)
			response = @rds.servers
		else
			response = @rds.servers.all(filters)
		end
		[OK, response.to_json]
	end
	
	post '/databases' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @rds.servers.create(json_body["relational_database"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	delete '/databases/:id' do
		begin
			response = @rds.servers.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

	get '/engine_versions' do
		begin
			engine_versions = @rds.describe_db_engine_versions.body['DescribeDBEngineVersionsResult']['DBEngineVersions'].as_json
			engine_versions.each do |v|
				v.each_pair do |name, value|
					v[name] = value.strip
				end
			end
			[OK, engine_versions.to_json]
		rescue => error
			handle_error(error)
		end
	end

	get '/parameter_groups' do
		filters = params[:filters]
		if(filters.nil?)
			response = @rds.parameter_groups
		else
			response = @rds.parameter_groups.all(filters)
		end
		[OK, response.to_json]
	end

	get '/security_groups' do
		filters = params[:filters]
		if(filters.nil?)
			response = @rds.security_groups
		else
			response = @rds.security_groups.all(filters)
		end
		[OK, response.to_json]
	end
  
  #
  #Create Security Groups
  #
	post '/security_groups' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @rds.security_groups.create(json_body["security_group"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
  #
  #Delete Security Groups
  #
	delete '/security_groups/:id' do
		begin
			response = @rds.security_groups.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Create Parameter Groups
  #
	post '/parameter_groups' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @rds.parameter_groups.create(json_body["parameter_group"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
  
  #
  #Delete Parameter Groups
  #
	delete '/parameter_groups/:id' do
		begin
			response = @rds.parameter_groups.get(params[:id]).destroy
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
  
  #
  #Describe Parameter Group
  #
	post '/parameter_groups/describe/:id' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @rds.describe_db_parameters(params[:id],json_body["options"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
end
