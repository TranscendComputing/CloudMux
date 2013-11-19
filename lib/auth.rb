module Auth
  
    # Validate
    def Auth.validate(cred_id,service_name,action,options = nil)
        policies = Auth.find_group_policies(cred_id)
        policies.each    do |policy|
            if ! Auth.validatePolicy(cred_id,policy,service_name,action,options)
                return false
            end
        end
        return true
    end
    
    # Helper Functions
    def Auth.find_group_policies(cred_id)
        policies = []
        ac_id = Auth.find_account(cred_id).id
        Group.each do |group|
            group.group_memberships.each do |membership|
                if membership.account_id == ac_id
                    policies.push(group.group_policy)
                end
            end
        end
        return policies
    end
  
    def Auth.find_account(cloud_credential_id)
        return nil if cloud_credential_id.nil?
        account = Account.where({"cloud_credentials._id"=>Moped::BSON::ObjectId.from_string(cloud_credential_id.to_s)}).first
        (account.nil? ? nil : account)
    end

    #List of Actions
    def Auth.validatePolicy(cred_id,policy,service_name,action,options)
        if policy.nil?
            return true
        end

        #Check which cloud provider is being used.
        cloud_info = Account.find_cloud_credential(cred_id)
        if( cloud_info.cloud_provider === "OpenStack" )
            governance = policy.os_governance
            options = cloud_info.cloud_attributes.merge(:provider => "openstack")
        elsif (cloud_info.cloud_provider === "AWS")
            governance = policy.aws_governance
            options = cloud_info.cloud_attributes.merge(:provider => "AWS")
        else
            return true
        end

        #Determine which action is being taken.
        case action
        when "action"
            return Auth.canUseService(cred_id,governance['enabled_services'],service_name)
        when "create_instance"
            return Auth.canCreateInstance(governance['max_on_demand'],options)
        when "create_rds"
            return Auth.canCreateInstance(governance['max_rds'],options)
        when "create_spot"
            return Auth.canCreateInstance(governance['max_spot'],options)
        when "create_reserved"
            return Auth.canCreateInstance(governance['max_reserved'],options)
        when "create_autoscale"
            return Auth.canCreateInstance(governance['max_in_autoscale'],options)
        when "create_default_alarms"
            return Auth.createAlarms(governance,options)
        when "create_auto_tags"
            return Auth.createTags(policy,governance,options)
        when "create_vpc_instance"
            return Auth.createVpcInstance(governance,options)
        when "modify_gateway"
            return Auth.canModifyGateway(governance['vpc_rules'],options)
        end
        return true
    end
    
    #Enabled Services
    def Auth.canUseService(cred_id,enabled_services,service_name)
        return true if Auth.find_account(cred_id).permissions.length > 0
        if enabled_services.nil?
            return false
        elsif enabled_services.is_a? String
            if enabled_services == service_name
                return true
            end
        elsif enabled_services.is_a? Array
            enabled_services.each do |service|
                if service == service_name
                    return true
                end
            end
        end
        return false
    end
    
    #Max Instances
    def Auth.canCreateInstance(max_instance,options)
        @compute = Fog::Compute.new(options)
        if max_instance == ""
            return true
        elsif @compute.servers.count >= max_instance.to_i
            return false
        else return true
        end
    end
    
    #Modify Gateways
    def Auth.canModifyGateway(vpc_rules,gw_type)
        return false if !vpc_rules.include?(gw_type)
        return true
    end
    
    #default Alarms
    def Auth.createAlarms(aws_governance,options)
        resource_id = options[:resource_id]
        params = options[:params]
        namespace = options[:namespace]
        cloud_cred = Account.find_cloud_credential(params["cred_id"])
        @monitor = Fog::AWS::CloudWatch.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
        
        aws_governance['default_alarms'].each do |alarm|
            if alarm["namespace"] == namespace
                @monitor.alarms.create({"id"=>"SS_"+resource_id+"_"+alarm['id']+Time.now.to_i.to_s,
                                        "dimensions"=> [{"Name" => alarm['dimensions'][0]['Name'],"Value" => resource_id}],
                                        "metric_name"=> alarm['metric_name'],
                                        "threshold"=> alarm['threshold'],
                                        "namespace"=> alarm['namespace'],
                                        "comparison_operator"=> alarm['comparison_operator'],
                                        "statistic"=> "Average",
                                        "period"=> alarm['period'],
                                        "evaluation_periods"=> 1,
                                        "alarm_actions"=> alarm['alarm_actions'],
                                        "ok_actions"=> [],
                                        "insufficient_data_actions"=> []})
            end
        end
        
        return true
    end
    
    def Auth.createTags(policy,aws_governance,options)
        resource_id = options[:resource_id]
        params = options[:params]
        cloud_cred = Account.find_cloud_credential(params["cred_id"])
        account = Auth.find_account(params["cred_id"])
        @compute = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
        
        if aws_governance['auto_tags'].include?("ProjectName")
            @compute.tags.create(:resource_id => resource_id, :key => "ProjectName", :value => aws_governance['project_name'])
        end
        if aws_governance['auto_tags'].include?("UserName")
            @compute.tags.create(:resource_id => resource_id, :key => "UserName", :value => account['login'])
        end
        if aws_governance['auto_tags'].include?("GroupName")
            @compute.tags.create(:resource_id => resource_id, :key => "GroupName", :value => policy.name)
        end
        if aws_governance['auto_tags'].include?("Modifiable")
            @compute.tags.create(:resource_id => resource_id, :key => "Modifiable", :value => 'Modifiable')
        end
        
        return true
    end
    
    def Auth.createVpcInstance(aws_governance,options)
        instance = options[:instance]
        params = options[:params]
        cloud_cred = Account.find_cloud_credential(params["cred_id"])
        account = Auth.find_account(params["cred_id"])
        @compute = Fog::Compute::AWS.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
        if aws_governance['vpc_rules'].include?("require_vpc")
            instance['subnet_id'] = aws_governance['default_subnet']
            response = @compute.servers.create(instance)
            Auth.validate(params[:cred_id],"Elastic Compute Cloud","create_default_alarms",{:params => params, :resource_id => response.id, :namespace => "AWS/EC2"})
            Auth.validate(params[:cred_id],"Elastic Compute Cloud","create_auto_tags",{:params => params, :resource_id => response.id})
            return false
        end
        return true
    end
end
