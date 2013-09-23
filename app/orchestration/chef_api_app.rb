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
                chef_url = chef_config.protocol + "://" + chef_config.host
                if(!(chef_config.port != "" && chef_config.port != nil && chef_config.protocol == "https"))
                    chef_url.concat(":" + chef_config.port)
                end
                @chef = Chef::RestClient.new(chef_url, chef_config.auth_properties["client_name"], chef_config.auth_properties["key"]);
            else
                message= Error.new.extend(ErrorRepresenter)
                message.message = "Must configure a Chef server with the cloud account."
                halt [BAD_REQUEST, message.to_json]
            end
       else
          message = Error.new.extend(ErrorRepresenter)
          message.message = "Account ID must be passed in as a parameter"
          halt [BAD_REQUEST, message.to_json]
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
    get '/nodes/find' do
        name = params[:name];
        if(!name)
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must supply the name parameter"
            [BAD_REQUEST, message.to_json]
        else
            node = @chef.find_node(name);
            if(node)
                [OK, node.to_json]
            else
                [OK, {}.to_json]
            end
        end
    end
    post '/nodes/find' do
        names = JSON.parse(request.body.read)
        if(!names || names.length == 0)
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must supply names of instances to search for"
            [BAD_REQUEST, message.to_json]
        else
            nodes = @chef.find_nodes(names);
            [OK, nodes.to_json];
        end
    end
    get '/nodes/:node_name' do
        node = @chef.get_node(params[:node_name])
        [OK, node.to_json]
    end

    put '/nodes/:node_name' do
        begin
            updated_node = @chef.update_runlist(params[:node_name], request.body.read)
            [OK, updated_node.to_json]
        rescue MultiJson::DecodeError
            message= Error.new.extend(ErrorRepresenter)
            message.message = "Can only add role[] or recipe[] to run list."
            [BAD_REQUEST, message.to_json]
        rescue Spice::Error::NotFound => error
            message = Error.new.extend(ErrorRepresenter)
            message.message = error.message
            [BAD_REQUEST, message.to_json]
        end
    end
    
end