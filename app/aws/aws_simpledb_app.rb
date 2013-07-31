require 'sinatra'
require 'fog'

class AwsSimpleDBApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@sdb = Fog::AWS::SimpleDB.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@sdb = Fog::AWS::SimpleDB.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @sdb.nil?
    end

	#
	# Databases
	#
  ##~ sapi = source2swagger.namespace("aws_simple_db")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Databases"] = {:id => "Databases", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/simple_db/databases"
  ##~ a.description = "Manage Simple DB resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Databases (AWS cloud)"
  ##~ op.nickname = "describe_databases"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of databases returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/databases' do
		filters = params[:filters]
		if(filters.nil?)
			db_list = @sdb.list_domains.body["Domains"]
		else
			db_list = @sdb.list_domains.(filters).body["Domains"]
		end
		response = []
		db_list.each do |t|
			domain = @sdb.domain_metadata(t).body
			domain = domain.merge({"DomainName" => t})
			response << domain
		end
		[OK, response.to_json]
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/simple_db/databases"
  ##~ a.description = "Manage Simple DB resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Databases (AWS cloud)"
  ##~ op.nickname = "create_databases"  
  ##~ sapi.models["CreateDatabase"] = {:id => "CreateDatabase", :properties => {:DomainName => {:type => "string"}}}  
  ##~ op.parameters.add :name => "simple_db", :description => "Database to Create", :dataType => "CreateDatabase", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, databases created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/databases' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @sdb.create_domain(json_body["simple_db"]["DomainName"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/simple_db/databases/:id"
  ##~ a.description = "Manage Simple DB resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Databases (AWS cloud)"
  ##~ op.nickname = "delete_databases"   
  ##~ op.parameters.add :name => "id", :description => "Database to Delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, databases deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/databases/:id' do
		begin
			response = @sdb.delete_domain(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/simple_db/databases/select"
  ##~ a.description = "Manage Simple DB resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Select item data from Databases (AWS cloud)"
  ##~ op.nickname = "select_databases"   
  ##~ op.parameters.add :name => "select_expression", :description => "Select Expression", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, databases item data selected", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/databases/select' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["select_expression"])
			[BAD_REQUEST]
		else
			begin
				contents = @sdb.select(json_body["select_expression"]).body["Items"]
				response = []
				contents.each do |t|
					item = {}
					item["Name"] = t[0]
					item["Attributes"] = []
					t[1].each do |s|
						att = {}
						att["Name"] = s[0]
						att["Value"] = s[1]
						item["Attributes"] << att
					end
					response << item
				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/simple_db/databases/:id/items/:item_name"
  ##~ a.description = "Manage Simple DB resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Put item attributes into a SimpleDB domain (AWS cloud)"
  ##~ op.nickname = "put_attributes_databases"
  ##~ sapi.models["SimpleDBAttribute"] = {:id => "SimpleDBAttribute", :properties => {:name => {:type => "string"},:value => {:type => "string"}}}   
  ##~ op.parameters.add :name => "attributes", :description => "Attributes name/value pairs", :dataType => "Array", :items => {:$ref => "SimpleDBAttribute"}, :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.parameters.add :name => "id", :description => "Database to put attributes in", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "item_name", :description => "Item name", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, attributes put into SimpleDB domain", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	post '/databases/:id/items/:item_name' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @sdb.put_attributes(params[:id], params[:item_name], json_body["attributes"])
				[OK, response.to_json]
			rescue
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/simple_db/databases/:id/items/:item_name"
  ##~ a.description = "Manage Simple DB resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete attributes from a SimpleDB domain (AWS cloud)"
  ##~ op.nickname = "delete_attributes_databases"
  ##~ op.parameters.add :name => "id", :description => "Database to delete attributes from", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "item_name", :description => "Item name to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, attributes deleted from SimpleDB domain", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "region", :description => "Cloud region to examine", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	delete '/databases/:id/items/:item_name' do
		begin
			response = @sdb.delete_attributes(params[:id], params[:item_name])
			[OK, response.to_json]
		rescue
			handle_error(error)
		end
	end
end
