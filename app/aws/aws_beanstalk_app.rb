require 'sinatra'
require 'fog'

class AwsBeanstalkApp < ResourceApiBase
	
	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@elasticbeanstalk = Fog::AWS::ElasticBeanstalk.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@elasticbeanstalk = Fog::AWS::ElasticBeanstalk.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @elasticbeanstalk.nil?
    end
    
  	#
  	# Applications
  	#
  	get '/applications' do
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @elasticbeanstalk.applications
  		else
  			response = @elasticbeanstalk.applications.all(filters)
  		end
  		[OK, response.to_json]
  	end
    
  	post '/applications' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.applications.create(json_body["application"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
  
  	delete '/applications/:id' do
  		begin
  			response = @elasticbeanstalk.applications.get(params[:id]).destroy
  			[OK, response.to_json]
  		rescue => error
  			handle_error(error)
  		end
  	end
    
  	#
  	# Application Version
  	#
  	get '/applications/:appid/versions/:vid' do
  		begin
  			response = @elasticbeanstalk.versions.get(params[:appid],params[:vid])
  			[OK, response.to_json]
  		rescue => error
  			handle_error(error)
  		end
  	end
    
    #
    #Application Environments
    #
  	post '/applications/environments' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.describe_environments(json_body["options"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
    
    #
    #Application Versions
    #
  	post '/applications/versions' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.describe_application_versions(json_body["options"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
  
end