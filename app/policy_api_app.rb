require 'sinatra'

class PolicyApiApp < ApiBase
    # Fetch Policies
    get '/' do
        if ! params[:org_id].nil?
            policies = find_group_policies(params[:org_id])
            [OK, policies.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    # Fetch Rules
    get '/rules' do
        if ! params[:group_policy_id].nil?
            rules = GroupPolicy.find(params[:group_policy_id]).policy_rules
            [OK, rules.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    #Create Policy
    post '/' do
        policy_json = body_to_json(request)
        if ! policy_json.nil? && ! policy_json["name"].nil?
            policy = policy_json["policy"]
            policy_os = policy_json["policy_os"]
            name = policy_json["name"]
            myOrg = Org.find(params[:org_id])
            gp = GroupPolicy.new(
                name: name,
                os_governance: policy_os,
                aws_governance: policy,
                org: myOrg
            )
            gp.save!
            [OK, gp.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    #Create Rules for Policy
    post '/rules' do
        rule_json = body_to_json(request)
        if ! rule_json.nil? && ! rule_json["name"].nil?
            pr = PolicyRule.new(name: rule_json["name"], who: rule_json["who"], what: rule_json["what"], action: rule_json["action"])
            pr.save!
            gp = GroupPolicy.find(rule_json["group_policy_id"])
            gp.policy_rules << pr
            gp.save!
            [OK, pr.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    #Set Policy to Group
    post '/groups' do
        pg = body_to_json(request)
        policy_to_group = pg["policy"]
        if ((!policy_to_group.nil?) && (!policy_to_group["group_id"].nil?) && (!policy_to_group["group_policy_id"].nil?))
            group = Group.find(policy_to_group["group_id"])
            
            if policy_to_group["group_policy_id"] != "None"
                group_policy = GroupPolicy.find(policy_to_group["group_policy_id"])
            else
                group_policy = nil
            end
            
            group.group_policy = group_policy
            group.save!
            [OK, group.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    #debug here
    get '/debug' do
        #debugger
        [OK]
    end
    
    #Save Policy
    post '/:id' do
        policy_json = body_to_json(request)
        if ! policy_json.nil? && ! policy_json["name"].nil?
            policy = policy_json["policy"]
            name = policy_json["name"]
            policy_os = policy_json["policy_os"]
            updatePolicy = GroupPolicy.find(params[:id])
            updatePolicy.update_attributes(
              name: name,
              aws_governance: policy,
              os_governance: policy_os
            )
            [OK, updatePolicy.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    #Delete Policy
    delete '/:id' do
        if ! params[:id].nil?
            deletePolicy = GroupPolicy.find(params[:id])
            deletePolicy.destroy
            [OK, deletePolicy.to_json]
        else
            [BAD_REQUEST]
        end
    end
    
    def find_account(cloud_credential_id)
        Auth.find_account(cloud_credential_id)
    end
    
    def find_group_rules(cred_id)
        rules = []
        ac_id = find_account(cred_id).id
        Group.each do |group|
          group.group_memberships.each do |membership|
             if membership.account_id == ac_id && ! membership.group.group_policy.nil?
                 membership.group.group_policy.policy_rules.each do |rule|
                     rules.push(rule)
                 end
             end
          end
        end
        return rules
    end
    
    def find_group_policies(org_id)
        GroupPolicy.where(org_id: org_id).entries
    end
    
    def find_groups(cred_id)
        groups = []
        ac_id = find_account(cred_id).id
        Group.each do |group|
          group.group_memberships.each do |membership|
             if membership.account_id == ac_id
                 groups.push(group)
             end
          end
        end
        return groups
    end
    
	def body_to_json(request)
		if(!request.content_length.nil? && request.content_length != "0")
			return MultiJson.decode(request.body.read)
		else
			return nil
		end
	end
    
end