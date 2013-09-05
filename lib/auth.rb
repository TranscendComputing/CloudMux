module Auth
  
  def Auth.validate(cred_id,service_name,action)
      policies = Auth.find_group_policies(cred_id)
      policies.each do |policy|
          if ! Auth.validatePolicy(policy,service_name)
              return false
          end
      end
      return true
  end
  
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
  
  def Auth.validatePolicy(policy,service_name)
      if policy.nil?
          return true
      end
      aws_governance = policy.aws_governance
      if ! Auth.canUseService(aws_governance['enabled_services'],service_name)
          return false
      end
      return true
  end
  
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
  
end