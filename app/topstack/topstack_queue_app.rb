require 'sinatra'
require 'fog'

class TopStackQueueApp < ResourceApiBase

	before do
		if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                begin
                    # Find Monitor service endpoint
                    endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"SQS"}).first
                    halt [BAD_REQUEST] if endpoint.nil?
                    fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                    fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                    @sqs = Fog::AWS::SQS.new(fog_options)
                    halt [BAD_REQUEST] if @sqs.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# Queues
	#
	get '/queues' do
		filters = params[:filters]
		if(filters.nil?)
			list_response = @sqs.list_queues.body["QueueUrls"]
		else
			list_response = @sqs.list_queues(filters).body["QueueUrls"]
		end
		response = []
		list_response.each do |q|
			queue_url_split = q.split("/")
			if(queue_url_split.length > 0)
				#Queue name is last item in url path
				name = queue_url_split[queue_url_split.length - 1]
			else
				name = ""
			end
			queue = {"QueueUrl" => q, "QueueName" => name}
			#Even though a user can list all queues, they may not have access to get_queue_attributes
			begin
				attrs = @sqs.get_queue_attributes(q, "All").body["Attributes"]
            	queue.merge!(attrs)
            rescue
            	#Do Nothing
            	#This is incase they do not have permission, or deleted queue remains in list
            end
            response << queue
		end
		[OK, response.to_json]
	end

	post '/queues' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["queue"].nil?)
			[BAD_REQUEST]
		else
			begin
				queue = json_body["queue"]
				response = @sqs.create_queue(queue["QueueName"],{"VisibilityTimeout"=> queue["VisibilityTimeout"],
																"MessageRetentionPeriod"=> queue["MessageRetentionPeriod"],
																"MaximumMessageSize"=> queue["MaximumMessageSize"],
																"DelaySeconds"=> queue["DelaySeconds"],
																"ReceiveMessageWaitTimeSeconds"=> queue["ReceiveMessageWaitTimeSeconds"]})
				queue.delete("QueueName");
				queue.keys.each do |key|
        			@sqs.set_queue_attributes(response.body["QueueUrl"], key, queue[key])
   				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end

	delete '/queues' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["queue"].nil?)
			[BAD_REQUEST]
		else
			begin
				response = @sqs.delete_queue(json_body["queue"]["QueueUrl"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
end
