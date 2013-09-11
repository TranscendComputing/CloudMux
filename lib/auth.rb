module Auth
  
    # Validate
    def Auth.validate(cred_id,service_name,action,options = nil)
        policies = Auth.find_group_policies(cred_id)
        policies.each do |policy|
            if ! Auth.validatePolicy(policy,service_name,action,options)
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
    def Auth.validatePolicy(policy,service_name,action,options)
        if policy.nil?
            return true
        end
        aws_governance = policy.aws_governance
        if action == 'action' && ! Auth.canUseService(aws_governance['enabled_services'],service_name)
            return false
        elsif action == 'create_instance' && ! Auth.canCreateInstance(aws_governance['max_on_demand'],options)
            return false
        elsif action == 'create_rds' && ! Auth.canCreateInstance(aws_governance['max_rds'],options)
            return false
        elsif action == 'create_spot' && ! Auth.canCreateInstance(aws_governance['max_spot'],options)
            return false
        elsif action == 'create_reserved' && ! Auth.canCreateInstance(aws_governance['max_reserved'],options)
            return false
        elsif action == 'create_autoscale' && ! Auth.canCreateInstance(aws_governance['max_in_autoscale'],options)
            return false
        end
        return true
    end
    
    #Enabled Services
    def Auth.canUseService(enabled_services,service_name)
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
        if max_instance == ""
            return true
        elsif options >= max_instance.to_i
            return false
        else return true
        end
    end
end