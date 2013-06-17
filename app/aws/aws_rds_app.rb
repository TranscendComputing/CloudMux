require 'sinatra'
require 'fog'

class AwsRdsApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@rds = Fog::AWS::RDS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@rds = Fog::AWS::RDS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @rds.nil?
    end

	#
	# Volumes
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
end
