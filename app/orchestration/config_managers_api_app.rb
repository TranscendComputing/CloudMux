require 'sinatra'
require 'debugger'
require 'json'

class ConfigManagerApiApp < ApiBase
  
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
    
    post '/' do
        if params[:org_id].nil?
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must provide org_id with request for configuration managers."
            [BAD_REQUEST, message.to_json]
        else
            body = request.body.read
            new_manager = ConfigManager.new.extend(UpdateConfigManagerRepresenter)
            new_manager.from_json(body)
            new_manager.org = Org.find(params[:org_id]).extend(OrgRepresenter)
            new_manager.save!
            [OK, new_manager.to_json]
        end
    end

    delete '/:manager_id' do
        begin
            ConfigManager.find(params[:manager_id]).delete
            [OK, {:message=>"Configuration manager deleted."}.to_json]
        rescue Mongoid::Errors::DocumentNotFound => error
            [NOT_FOUND, "Configuration manager does not exist in database."]
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

    put '/:manager_id' do
        attrs = JSON.parse(request.body.read)
        manager = ConfigManager.find(params[:manager_id]);
        result = manager.update_attributes!(attrs)
        if(result)
            [OK, {:message=>"Successfully updated configuration manager."}.to_json]
        else
            [BAD_REQUEST, {:message=>"Could not update configuration manager"}.to_json]
        end
    end


    get '/account/:account_id' do
        account = CloudAccount.find(params[:account_id]).extend(UpdateCloudAccountRepresenter)
        [OK, account.config_managers.to_json]
    end
end