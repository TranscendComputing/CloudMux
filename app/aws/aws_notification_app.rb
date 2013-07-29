require 'sinatra'
require 'fog'

class AwsNotificationApp < ResourceApiBase

	before do
		if ! params[:cred_id].nil?
			cloud_cred = get_creds(params[:cred_id])
			if ! cloud_cred.nil?
				if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
					@notification = Fog::AWS::SNS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					@notification = Fog::AWS::SNS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
				end
			end
		end
		halt [BAD_REQUEST] if @notification.nil?
    end

	#
	# Topics
	#
  ##~ sapi = source2swagger.namespace("aws_notification")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Topics"] = {:id => "Topics", :properties => {:id => {:type => "string"}, :availability_zones => {:type => "string"}, :launch_configuration_name => {:type => "string"}, :max_size => {:type => "string"}, :min_size => {:type => "string"}}}
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/topics/list"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "List Topics (AWS cloud)"
  ##~ op.nickname = "list_topics"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of topics returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	get '/topics/list' do
		filters = params[:filters]
		if(filters.nil?)
			raw_response = @notification.list_topics.body["Topics"]
		else
			raw_response = @notification.list_topics(filters).body["Topics"]
		end
		response = []
		raw_response.each {|t| response.push({"id"=> t})}
		[OK, response.to_json]
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/topics"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Topics (AWS cloud)"
  ##~ op.nickname = "describe_topics"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for topics", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Success, list of topics returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	get '/topics' do
		filters = params[:filters]
		if(filters.nil?)
			raw_response = @notification.list_topics.body["Topics"]
		else
			raw_response = @notification.list_topics(filters).body["Topics"]
		end
		response = []
		raw_response.each do |t|
			topic = {}
			topic["id"] = t
			begin
				topic["Name"] = t.split(":").last
				attributes = @notification.get_topic_attributes(t).body["Attributes"]
				topic.merge!(attributes)
			rescue
			end
			response.push(topic)
		end
		[OK, response.to_json]
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/topics"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Topics (AWS cloud)"
  ##~ op.nickname = "create_topics"
  ##~ sapi.models["CreateTopic"] = {:id => "CreateTopic", :properties => {:name => {:type => "string"}}}  
  ##~ op.parameters.add :name => "topic", :description => "Topic to Create", :dataType => "CreateTopic", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, topic created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/topics' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @notification.create_topic(json_body["topic"]["name"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/topics/:id"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Topics (AWS cloud)"
  ##~ op.nickname = "delete_topics"
  ##~ op.parameters.add :name => "id", :description => "Topic to delete", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, topic deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	delete '/topics/:id' do
		if(params[:id].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @notification.delete_topic(params[:id])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	#
	# Subscriptions
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/topics/:id/subscriptions"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Subscriptions (AWS cloud)"
  ##~ op.nickname = "describe_subscriptions"  
  ##~ op.parameters.add :name => "filters", :description => "Filters for subscriptions", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "id", :description => "Topic to get subscriptions for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, list of topic subscriptions returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	get '/topics/:id/subscriptions' do
		filters = params[:filters]
		begin
			if(filters.nil?)
				response = @notification.list_subscriptions_by_topic(params[:id]).body["Subscriptions"]
			else
				response = @notification.list_subscriptions_by_topic(params[:id], filters).body["Subscriptions"]
			end
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/topics/:id/subscriptions"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Subscriptions (AWS cloud)"
  ##~ op.nickname = "create_subscriptions"
  ##~ sapi.models["CreateSubscription"] = {:id => "CreateSubscription", :properties => {:endpoint => {:type => "string"},:protocol => {:type => "string"}}}
  ##~ op.parameters.add :name => "id", :description => "Topic to get subscriptions for", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "subscription", :description => "Subscription to create", :dataType => "CreateSubscription", :allowMultiple => false, :required => true, :paramType => "body"
  ##~ op.errorResponses.add :reason => "Success, subscription created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	post '/topics/:id/subscriptions' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @notification.subscribe(params[:id], json_body["subscription"]["endpoint"], json_body["subscription"]["protocol"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/aws/notification/subscriptions/:id"
  ##~ a.description = "Manage Notification resources on the cloud (AWS)"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Unsuscribe subscriptions (AWS cloud)"
  ##~ op.nickname = "unsubscribe_subscriptions"
  ##~ op.parameters.add :name => "id", :description => "Subscription to unsubscribe", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success, unsubscribed", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
	delete '/subscriptions/:id' do
		if(params[:id].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @notification.unsubscribe(params[:id])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
end
