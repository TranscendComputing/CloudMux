require 'sinatra'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'chef', 'rest_client.rb')

class ChefApiApp < ApiBase

    before do
        if(params[:account_id])
            cloud_acc = CloudAccount.find(params[:account_id]);
            chef_config = cloud_acc.config_managers.select {|c| c["type"] == "chef"}[0]
            if(chef_config)
                chef_url = chef_config.protocol + "://" + chef_config.host + ":" + chef_config.port;
                @chef = Chef::RestClient.new(chef_url, chef_config.auth_properties["node_name"], chef_config.auth_properties["key"]);
            else
                message= Error.new.extend(ErrorRepresenter)
                message.message = "Must configure a Chef server with the cloud account."
                [BAD_REQUEST, message.to_json]
            end
       else
          message = Error.new.extend(ErrorRepresenter)
          message.message = "Account ID must be passed in as a parameter"
          [BAD_REQUEST, message.to_json]
        end
    end
    
    get '/cookbooks' do
        cookbooks = @chef.list_cookbooks
        [OK, cookbooks.to_json]
    end

    get '/cookbooks/:name/:version' do
        recipes = @chef.get_recipes(params[:name], params[:version])
        [OK, recipes.to_json]
    end

    get '/environments' do
        environments = @chef.get_environments();
        [OK, environments.to_json]
    end

    get '/environments/:env_name' do
        env = @chef.get_environment(params[:env_name])
        [OK, env.to_json]
    end

    get '/roles' do
        roles = @chef.get_roles();
        [OK, roles.to_json]
    end

    get '/roles/:role_name' do
        role = @chef.get_role(params[:role_name]);
        [OK, role.to_json]
    end

    get '/nodes' do
        nodes = @chef.get_nodes()
        [OK, nodes.to_json]
    end

    get '/nodes/:node_name' do
        node = @chef.get_node(params[:node_name])
        [OK, node.to_json]
    end

    put '/nodes/:node_name' do
        node = @chef.get_node(params[:node_name])
        body = request.body.read
        updated_node = @chef.update_node(params[:node_name], body)
        [OK, updated_node.to_json]
    end
end