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

	delete '/topics/:id' do
		begin
			response = @notification.delete_topic(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

	post '/topics/:id/publish' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				if(json_body["publish"]["options"].nil?)
					response = @notification.publish(params[:id], json_body["publish"]["message"])
				else
					response = @notification.publish(params[:id], json_body["publish"]["message"], json_body["publish"]["options"])
				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	post '/topics/:id/set_attribute' do
		json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @notification.set_topic_attributes(params[:id], json_body["attribute"]["name"], json_body["attribute"]["value"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	#
	# Subscriptions
	#
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
