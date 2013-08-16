require 'sinatra'
# require 'spice'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__), '..', 'lib', 'puppet', 'rest_client.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'chef', 'rest_client.rb')

class OrchestrationApiApp < ApiBase

    before do
        if(params[:account_id])
            cloud_acc = CloudAccount.find(params[:account_id]);
            chef_config = cloud_acc.config_managers.select {|c| c["type"] == "chef"}[0]
            # puppet_config = cloud_acc.config_managers.select {|c| c["type"] == "puppet"}[0]
            # if(puppet_config)
            #     puppet_url = puppet_config.protocol + "://" + puppet_config.host + ":" + puppet_config.port;
            #     auth = puppet_config.auth_properties;
            #     @puppet = Puppet::RestClient.new(puppet_url, auth["key"], auth["cert"], auth["cacert"], "production")
            # end
            if(chef_config)
                chef_url = chef_config.protocol + "://" + chef_config.host + ":" + chef_config.port;
                @chef = Chef::RestClient.new(chef_url, chef_config.auth_properties["node_name"], chef_config.auth_properties["key"]);
            end
        end
    end

    # get '/puppet/modules' do 
    #     if(params[:account_id].nil?)
    #         halt [BAD_REQUEST]
    #     end
    #     modules = @puppet.list_module_resources
    #     [OK, modules.to_json]
    # end

    get '/chef/cookbooks' do
        cookbooks = @chef.list_cookbooks
        [OK, cookbooks.to_json]
    end

    get '/chef/recipes/:name/:version' do
        recipes = @chef.get_recipes(params[:name], params[:version])
        [OK, recipes.to_json]
    end
    # get '/' do
    #     all = {};
    #     all["puppet"] = @puppet.list_module_resources
    #     all["chef"] = @chef.list_cookbooks
    #     [OK, all.to_json]

    # end
    #VERY SLOW.  Shouldn't use, but leaving in for any potential use.
    # get '/chef/recipes' do
    #     resources = []
    #     @chef.cookbooks.each do |cookbook|
    #         recipe_versions = {}
    #         cookbook.versions.each do |version|
    #             @chef.cookbook_version(cookbook.name, version).metadata["recipes"].each do |recipe|
    #                 name = recipe[0]
    #                 desc = recipe[1]
    #                 if(recipe_versions[name] == nil)
    #                     recipe_versions[name] = []
    #                 end
    #                 recipe_versions[name] << version
    #             end

    #         end
    #         recipe_versions.each do |key,value|
    #             resources << {:name => key, :type=>"recipe", :versions=>value}
    #         end
    #     end
    #     [OK, resources.to_json]
    # end
  
    get '/manager' do
        if params[:org_id].nil?
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must provide org_id with request for configuration managers."
            [BAD_REQUEST, message.to_json]
        else
            org = Org.find(params[:org_id]).extend(OrgRepresenter)
            [OK, org.config_managers.to_json]
        end
    end
    
    post '/manager' do
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

    delete '/manager/:manager_id' do
        ConfigManager.find(params[:manager_id]).delete
        [OK]
    end

    get '/account/:account_id' do
        account = CloudAccount.find(params[:account_id]).extend(UpdateCloudAccountRepresenter)
        [OK, account.config_managers.to_json]
    end
    post '/manager/:manager_id/account' do
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
end