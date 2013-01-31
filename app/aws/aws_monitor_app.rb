require 'sinatra'
require 'fog'

class AwsMonitorApp < ResourceApiBase
	#
	# Alarms
	#
	post '/alarms/describe' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				response = monitor.alarms
			else
				filters = json_body["filters"]
				response = monitor.alarms.all(filters)
			end
			[OK, response.to_json]
		end
	end
	
	put '/alarms/create' do
		monitor = get_monitor_interface(params[:cred_id])
		if(monitor.nil?)
			[BAD_REQUEST]
		else
			json_body = body_to_json(request)
			if(json_body.nil?)
				[BAD_REQUEST]
			else
				response = monitor.alarms.create(json_body["alarm"])
				[OK, response.to_json]
			end
		end
	end

	def get_monitor_interface(cred_id)
		if(cred_id.nil?)
			return nil
		else
			cloud_cred = Account.find_cloud_account(cred_id)
			if cloud_cred.nil?
				return nil
			else
				return Fog::AWS::CloudWatch.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
			end
		end
	end
end
