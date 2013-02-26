require 'sinatra'
require 'fog'

class AwsNotificationApp < ResourceApiBase
	#
	# Topics
	#
	get '/topics/describe' do
		notification = get_notification_interface(params[:cred_id])
		if(notification.nil?)
			[BAD_REQUEST]
		else
			filters = params[:filters]
			if(filters.nil?)
				raw_response = notification.list_topics.body["Topics"]
			else
				raw_response = notification.list_topics(filters).body["Topics"]
			end
			response = []
			raw_response.each {|t| response.push({"id"=> t})}
			[OK, response.to_json]
		end
	end


	def get_notification_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = Account.find_cloud_account(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::AWS::SNS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
