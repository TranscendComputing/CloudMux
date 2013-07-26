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
	
	delete '/databases/:id' do
		begin
			response = @sdb.delete_domain(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
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

	delete '/databases/:id/items/:item_name' do
		begin
			response = @sdb.delete_attributes(params[:id], params[:item_name])
			[OK, response.to_json]
		rescue
			handle_error(error)
		end
	end
end
