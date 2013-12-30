require 'sinatra'
require 'json'

class ConfigManagerApiApp < ApiBase

    # Get a Config Manager by ID
    get '/:id' do
       cm = ConfigManager.where(id:params[:id]).first
        if cm.nil?
            [NOT_FOUND]
        else
            [OK, cm.to_json]
        end
    end

    # Get Config Managers for org
    get '/org/:org_id' do
        cms = ConfigManager.where(org_id:params[:org_id])
        response = []
        cms.each do |cm|
            response << cm.as_json
        end
        [OK, response.to_json]
    end
  
    get '/' do
        if params[:org_id].nil?
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must provide org_id with request for configuration managers."
            [BAD_REQUEST, message.to_json]
        else
            org = Org.find(params[:org_id]).extend(OrgRepresenter)
            [OK, org.config_managers.to_json]
        end
    end

    # Create a Config Manager
    post '/' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else
            case json_body["type"]
                when "chef"
                    new_manager = ChefConfigurationManager.new(json_body)
                when "puppet"
                    # TODO new Puppet that inherits ConfigManager
                    new_manager = ConfigManager.new(json_body)
                when "salt"
                    # TODO new Salt that inherits ConfigManager
                    new_manager = ConfigManager.new(json_body)
                when "ansible"
                    # TODO new Ansible that inherits ConfigManager
                    new_manager = ConfigManager.new(json_body)
                else
                    new_manager = ConfigManager.new(json_body)
            end
            if new_manager.valid?
                new_manager.save!
                [CREATED, new_manager.to_json]
            else
                [BAD_REQUEST]
            end
        end
    end
    
    # Update a Config Manager
    put '/:id' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else 
            update_cm = ConfigManager.where(id:params[:id]).first
            if update_cm.nil?
                [NOT_FOUND]
            else
                begin
                    update_cm.update_attributes!(json_body)
                    [OK, update_cm.to_json]
                rescue => e
                    [BAD_REQUEST]
                end
            end
        end
    end

    # Delete a Config Manager
    delete '/:id' do
        cm = ConfigManager.where(id:params[:id]).first
        if cm.nil?
            [NOT_FOUND]
        else
            cm.delete
            [OK, {"message"=> "Config Manager Deleted"}.to_json]
        end
    end

    post '/:manager_id/account' do
        if params[:account_id].nil?
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must provide account_id with request"
            [BAD_REQUEST, message.to_json]
        else
            account = CloudAccount.find(params[:account_id]).extend(UpdateCloudAccountRepresenter);
            manager = ConfigManager.find(params[:manager_id])
            existing = account.config_managers.select {|c| c["type"] == manager.type}
            if(existing != [])
                if(existing[0].id != manager.id)
                    account.config_managers.delete(existing[0]);
                    account.config_managers.push(manager)
                end
            else
                account.config_managers.push(manager);
            end
            [OK, account.config_managers.to_json]
        end
    end

    get '/account/:account_id' do
        account = CloudAccount.find(params[:account_id]).extend(UpdateCloudAccountRepresenter)
        [OK, account.config_managers.to_json]
    end
end