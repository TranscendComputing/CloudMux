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
    ##~ sapi = source2swagger.namespace("beanstalk_aws")
    ##~ sapi.swaggerVersion = "1.1"
    ##~ sapi.apiVersion = "1.0"
    ##~ sapi.models["Application"] = {:id => "Application", :properties => {:name => {:type => "string"}, :description => {:type => "string"}}}
    ##~ sapi.models["Launch_Configuration"] = {:id => "Launch_Configuration", :properties => {:id => {:type => "string"}, :image_id => {:type => "string"}, :instance_type => {:type => "string"}}}
    ##~ sapi.models["Version"] = {:id => "Version", :properties => {:label => {:type => "string"}, :application_name => {:type => "string"}, :auto_create_application => {:type => "boolean"}, :description => {:type => "string"}, :source_bundle => {:type => "string"}}}
    ##~ sapi.models["Environment"] = {:id => "Environment", :properties => {:application_name => {:type => "string"}, :cname_prefix => {:type => "string"}, :description => {:type => "boolean"}, :name => {:type => "string"}, :option_settings => {:type => "string"}, :options_to_remove => {:type => "string"}, :solution_stack_name => {:type => "string"}, :template_name => {:type => "string"}, :version_label => {:type => "string"}}}
    ##~ sapi.models["Config_Options"] = {:id => "Config_Options", :properties => {:ApplicationName => {:type => "string"}, :EnvironmentName => {:type => "string"}, :SolutionStackName => {:type => "string"}, :TemplateName => {:type => "string"}}}
    ##~ sapi.models["Event"] = {:id => "Event", :properties => {:EventDate => {:type => "string"}, :Severity => {:type => "string"}, :Message => {:type => "string"}, :EnvironmentName => {:type => "string"}}}

    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Application"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Beanstalk Applications (AWS cloud)"
    ##~ op.nickname = "describe_beanstalk_applications"  
    ##~ op.parameters.add :name => "filters", :description => "Filters for apps", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, list of Beanstalk Applications returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	get '/applications' do
  		filters = params[:filters]
  		if(filters.nil?)
  			response = @elasticbeanstalk.applications
  		else
  			response = @elasticbeanstalk.applications.all(filters)
  		end
  		[OK, response.to_json]
  	end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Application"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create a new Beanstalk Application (AWS cloud)"  
    ##~ op.nickname = "create_beanstalk_applications"
    ##~ op.parameters.add :name => "application", :description => "Application template to use", :dataType => "Application", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, new Beanstalk Application returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400	
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
  
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/:id"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Application"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete a new Beanstalk Application (AWS cloud)"  
    ##~ op.nickname = "delete_beanstalk_applications"
    ##~ op.parameters.add :name => "id", :description => "ID to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Application deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400	
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
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/:appid/versions/:vid"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Version"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Beanstalk Version (AWS cloud)"
    ##~ op.nickname = "describe_beanstalk_versions"  
    ##~ op.parameters.add :name => "appid", :description => "Application ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "vid", :description => "Version ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Version returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
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
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/environments"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Environment"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Describe Beanstalk Environments (AWS cloud)"
    ##~ op.nickname = "describe_beanstalk_environments"  
    ##~ op.parameters.add :name => "options", :description => "Environment Options", :dataType => "Environment", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Environments returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
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
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/environments/:id"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Environment"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Beanstalk Environments (AWS cloud)"
    ##~ op.nickname = "delete_beanstalk_environments"  
    ##~ op.parameters.add :name => "id", :description => "Environment ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Environment deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	delete '/applications/environments/:id' do
  		begin
  			response = @elasticbeanstalk.environments.get(params[:id]).destroy
  			[OK, response.to_json]
  		rescue => error
  			handle_error(error)
  		end
  	end
    
  	get '/applications/environments/:id' do
  		begin
  			response = @elasticbeanstalk.environments.get(params[:id])
  			[OK, response.to_json]
  		rescue => error
  			handle_error(error)
  		end
  	end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/environments/config"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Config_Options"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Describe Beanstalk Environment Configuration (AWS cloud)"
    ##~ op.nickname = "describe_beanstalk_environments_configuration"  
    ##~ op.parameters.add :name => "options", :description => "Environment Config Options", :dataType => "Config_Options", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Environment Config Returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	post '/applications/environments/config' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.describe_configuration_settings(json_body["options"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
    
    #
    #Application Versions
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/versions"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Version"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Describe Beanstalk Versions (AWS cloud)"
    ##~ op.nickname = "describe_beanstalk_app_versions"  
    ##~ op.parameters.add :name => "options", :description => "Versions Options", :dataType => "Version", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Versions returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
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
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/:appid/versions/:vid"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Version"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Beanstalk Versions (AWS cloud)"
    ##~ op.nickname = "delete_beanstalk_versions"  
    ##~ op.parameters.add :name => "appid", :description => "Application ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.parameters.add :name => "vid", :description => "Version ID", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Versions returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	delete '/applications/:appid/versions/:vid' do
  		begin
  			response = @elasticbeanstalk.versions.get(params[:appid],params[:vid]).destroy
  			[OK, response.to_json]
  		rescue => error
  			handle_error(error)
  		end
  	end
    
    #
    #Application Version Create
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/versions/create"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Version"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create Beanstalk Versions (AWS cloud)"
    ##~ op.nickname = "create_beanstalk_app_versions"  
    ##~ op.parameters.add :name => "version", :description => "Versions Options", :dataType => "Version", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, new Beanstalk Version returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	post '/applications/versions/create' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.create_application_version(json_body["version"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
    
    #
    #Application Environment Create
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/environments/create"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Environment"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create Beanstalk Environments (AWS cloud)"
    ##~ op.nickname = "create_beanstalk_environments"  
    ##~ op.parameters.add :name => "environment", :description => "Environment to Create", :dataType => "Environment", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Environment created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	post '/applications/environments/create' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.create_environment(json_body["environment"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/environments/update"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Environment"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Update Beanstalk Environments (AWS cloud)"
    ##~ op.nickname = "update_beanstalk_environments"  
    ##~ op.parameters.add :name => "environment", :description => "Environment to Update", :dataType => "Environment", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Environment updated", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    #Application Environment Update
  	post '/applications/environments/update' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.update_environment(json_body["environment"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
    
    #
    #Application Events
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/aws/beanstalk/applications/events"
    ##~ a.description = "Manage Beanstalk Applications on the cloud (AWS)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Event"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Describe Beanstalk Events (AWS cloud)"
    ##~ op.nickname = "describe_beanstalk_app_events"  
    ##~ op.parameters.add :name => "options", :description => "Event Options", :dataType => "Application", :allowMultiple => false, :required => true, :paramType => "body"
    ##~ op.errorResponses.add :reason => "Success, Beanstalk Events returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  	post '/applications/events' do
  		json_body = body_to_json(request)
  		if(json_body.nil?)
  			[BAD_REQUEST]
  		else
  			begin
  				response = @elasticbeanstalk.describe_events(json_body["options"])
  				[OK, response.to_json]
  			rescue => error
  				handle_error(error)
  			end
  		end
  	end
  
end