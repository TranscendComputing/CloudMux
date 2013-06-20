require 'sinatra'
require 'fog'

class OpenstackAutoscaleApp < ResourceApiBase

	before do
		if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                begin
                    # Find AutoScale service endpoint
                    endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"AutoScale"}).first
                    halt [BAD_REQUEST] if endpoint.nil?
                    fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                    fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                    @autoscale = Fog::AWS::AutoScaling.new(fog_options)
                    halt [BAD_REQUEST] if @autoscale.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# Autoscale Groups
	#
	get '/autoscale_groups' do
		filters = params[:filters]
		if(filters.nil?)
			response = @autoscale.groups
		else
			response = @autoscale.groups.all(filters)
		end
		[OK, response.to_json]
	end

	post '/autoscale_groups' do
		json_body = body_to_json(request)
		if(json_body.nil? || json_body["launch_configuration"].nil? || json_body["autoscale_group"].nil?)
			[BAD_REQUEST]
		else
			begin
				launch_config = json_body["launch_configuration"]
				autoscale_group = json_body["autoscale_group"]

				@autoscale.configurations.create(launch_config)
				response = @autoscale.groups.create(autoscale_group)

				if(json_body["trigger"])
					set_monitor_interface(params[:cred_id], params[:region])
					trigger = json_body["trigger"]
					#create scale up policy and metric alarm
		            scale_up_name = autoscale_group["AutoScalingGroupName"] + "ScaleUpPolicy"
		            up_policy = @autoscale.put_scaling_policy("ChangeInCapacity", autoscale_group["AutoScalingGroupName"], scale_up_name, trigger["scale_increment"]).body["PutScalingPolicyResult"]["PolicyARN"]
					up_options = {
						"AlarmName" => autoscale_group["AutoScalingGroupName"] + trigger["trigger_measurement"] + "UpAlarm",
						"AlarmActions" => [up_policy],
						"Dimensions" => [{"Name" => "AutoScalingGroupName", "Value" => autoscale_group["AutoScalingGroupName"]}],
						"ComparisonOperator" => "GreaterThanThreshold",
						"Namespace" => "AWS/EC2",
						"EvaluationPeriods" => 1,
						"MetricName" => trigger["trigger_measurement"],
						"Period" => trigger["measure_period"],
						"Statistic" => trigger["statistic"],
						"Threshold" => trigger["upper_threshold"],
						"Unit" => trigger["unit"]
					}
					@monitor.put_metric_alarm(up_options)
		   			#create scale down policy and metric alarm
		   			scale_down_name = autoscale_group["AutoScalingGroupName"] + "ScaleDownPolicy"
		   			down_policy = @autoscale.put_scaling_policy("ChangeInCapacity", autoscale_group["AutoScalingGroupName"], scale_down_name, trigger["scale_decrement"]).body["PutScalingPolicyResult"]["PolicyARN"]
		   			down_options = {
		   				"AlarmName" => autoscale_group["AutoScalingGroupName"] + trigger["trigger_measurement"] + "DownAlarm",
						"AlarmActions" => [down_policy],
						"Dimensions" => [{"Name" => "AutoScalingGroupName", "Value" => autoscale_group["AutoScalingGroupName"]}],
						"ComparisonOperator" => "LessThanThreshold",
						"Namespace" => "AWS/EC2",
						"EvaluationPeriods" => 1,
						"MetricName" => trigger["trigger_measurement"],
						"Period" => trigger["measure_period"],
						"Statistic" => trigger["statistic"],
						"Threshold" => trigger["lower_threshold"],
						"Unit" => trigger["unit"]
		   			}
		   			@monitor.put_metric_alarm(down_options)
				end
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
	post '/autoscale_groups/:id/spin_down' do
		begin
			response = @autoscale.update_auto_scaling_group(params[:id], {"MinSize" => 0, "MaxSize" => 0, "DesiredCapacity" => 0})
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	delete '/autoscale_groups/:id' do
		begin
			policies = @autoscale.describe_policies({"AutoScalingGroupName" => params[:id]}).body["DescribePoliciesResult"]["ScalingPolicies"]
			policies.each do |t|
				@autoscale.delete_policy(params[:id], t["PolicyName"]) unless t["PolicyName"].nil?
			end
			response = @autoscale.groups.get(params[:id]).destroy
			launch_config = @autoscale.configurations.get(params[:id]+"-lc")
			if ! launch_config.nil?
				launch_config.destroy
			end
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end

	def set_monitor_interface(cred_id, region)
		cloud_cred = get_creds(cred_id)
		if cloud_cred.nil?
			return nil
		else
			# Find Monitor service endpoint
            endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"Monitor"}).first
            fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
            fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
            @monitor = Fog::AWS::CloudWatch.new(fog_options)
		end
	end
end
