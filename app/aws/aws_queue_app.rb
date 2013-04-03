require 'sinatra'
require 'fog'

class AwsQueueApp < ResourceApiBase
	#
	# Topics
	#
	get '/queues/describe' do
		sqs = get_sqs_interface(params[:cred_id], params[:region])
		if(sqs.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				list_response = sqs.list_queues.body["QueueUrls"]
			else
				list_response = sqs.list_queues(filters).body["QueueUrls"]
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
					attrs = sqs.get_queue_attributes(q, "All").body["Attributes"]
                	queue.merge!(attrs)
                rescue
                	#Do Nothing
                	#This is incase they do not have permission, or deleted queue remains in list
                end
                response << queue
			end
			[OK, response.to_json]
		end
	end

	put '/queues/create' do
		sqs = get_sqs_interface(params[:cred_id], params[:region])
		if(sqs.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["queue"].nil?)
				[BAD_REQUEST]
			else
				begin
					queue = json_body["queue"]
					response = sqs.create_queue(queue["QueueName"],{"VisibilityTimeout"=> queue["VisibilityTimeout"],
																	"MessageRetentionPeriod"=> queue["MessageRetentionPeriod"],
																	"MaximumMessageSize"=> queue["MaximumMessageSize"],
																	"DelaySeconds"=> queue["DelaySeconds"],
																	"ReceiveMessageWaitTimeSeconds"=> queue["ReceiveMessageWaitTimeSeconds"]})
					queue.delete("QueueName");
					queue.keys.each do |key|
            			sqs.set_queue_attributes(response.body["QueueUrl"], key, queue[key])
       				end
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	delete '/queues/delete' do
		sqs = get_sqs_interface(params[:cred_id], params[:region])
		if(sqs.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil? || json_body["queue"].nil?)
				[BAD_REQUEST]
			else
				begin
					response = sqs.delete_queue(json_body["queue"]["QueueUrl"])
					[OK, response.to_json]
				rescue => error
					handle_error(error)
				end
			end
		end
	end

	def get_sqs_interface(cred_id, region)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = get_creds(cred_id)
			if cloud_cred.nil?
				return nil
			else
				if region.nil? or region == "undefined" or region == ""
					return Fog::AWS::SQS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
				else
					return Fog::AWS::SQS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => region})
				end
			end
		end
	end
end
