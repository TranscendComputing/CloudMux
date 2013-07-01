require 'sinatra'
require 'fog'

class TopStackLoadBalancerApp < ResourceApiBase

    before do
        if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                begin
                    # Find LoadBalancer service endpoint
                    endpoint = cloud_cred.cloud_account.cloud_services.where({"service_type"=>"ELB"}).first
                    halt [BAD_REQUEST] if endpoint.nil?
                    fog_options = {:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key}
                    fog_options.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
                    @elb = Fog::AWS::ELB.new(fog_options)
                    halt [BAD_REQUEST] if @elb.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

    #
    # Load Balancers
    #
    get '/load_balancers' do
        filters = params[:filters]
        if(filters.nil?)
            response = @elb.load_balancers
        else
            response = @elb.load_balancers.all(filters)
        end
        [OK, response.to_json]
    end
    
    post '/load_balancers' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                lb = json_body["load_balancer"]
                if lb["options"].nil?
                    response = @elb.create_load_balancer(lb["availability_zones"], lb["id"], lb["listeners"])
                else
                    response = @elb.create_load_balancer(lb["availability_zones"], lb["id"], lb["listeners"], lb["options"])
                end
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    delete '/load_balancers/:id' do
        begin
            response = @elb.load_balancers.get(params[:id]).destroy
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    post '/load_balancers/:id/configure_health_check' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.configure_health_check(params[:id], json_body["health_check"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    post '/load_balancers/:id/availability_zones/enable' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["availability_zones"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.enable_availability_zones_for_load_balancer(json_body["availability_zones"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    post '/load_balancers/:id/availability_zones/disable' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["availability_zones"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.disable_availability_zones_for_load_balancer(json_body["availability_zones"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    post '/load_balancers/:id/instances/register' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["instance_ids"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.register_instances_with_load_balancer(json_body["instance_ids"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    post '/load_balancers/:id/instances/deregister' do
        json_body = body_to_json(request)
        if(json_body.nil? || json_body["instance_ids"].nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.deregister_instances_from_load_balancer(json_body["instance_ids"], params[:id])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    get '/load_balancers/:id/describe_health' do
        if(params[:availability_zones].nil?)
            [BAD_REQUEST]
        else
            begin
                availability_zones_health = []
                availability_zones = JSON.parse(params[:availability_zones])
                availability_zones.each do |az|
                    az_health = {}
                    az_health["LoadBalancerName"] = params[:id]
                    az_health["AvailabilityZone"] = az
                    az_health["InstanceCount"] = 0
                    az_health["Healthy"] = false
                    availability_zones_health << az_health
                end
                instance_health = @elb.describe_instance_health(params[:id]).body["DescribeInstanceHealthResult"]["InstanceStates"]
                get_compute_interface(params[:cred_id])
                instance_health.each do |i|
                    instance = @compute.servers.get(i["InstanceId"])
                    if(!instance.nil?)
                        i["AvailabilityZone"] = instance.availability_zone
                        availability_zones_health.each do |a|
                            if a["AvailabilityZone"] == i["AvailabilityZone"]
                                a["InstanceCount"] = a["InstanceCount"] + 1
                                if i["State"] == "InService"
                                    a["Healthy"] = true
                                end
                            end
                        end
                    end
                end
                response = {"AvailabilityZonesHealth" => availability_zones_health, "InstancesHealth" => instance_health}
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    #
    # Load Balancer Listeners
    #
    get '/load_balancers/:id/listeners' do
        begin
            response = @elb.load_balancers.get(params[:id]).listeners
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    post '/load_balancers/:id/listeners' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.create_load_balancer_listeners(params[:id], json_body["listeners"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    delete '/load_balancers/:id/listeners' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @elb.delete_load_balancer_listeners(params[:id], json_body["ports"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end

    def get_compute_interface(cred_id)
        cloud_cred = get_creds(params[:cred_id])
        if cloud_cred.nil?
            return nil
        else
            options = cloud_cred.cloud_attributes.merge(:provider => "openstack")
            @compute = Fog::Compute.new(options)
            halt [BAD_REQUEST] if @compute.nil?
        end
    end
end
