require 'spice'
#require 'ridley'

class Chef
    class RestClient
    
    
        def initialize(url, client_name, key)
            Spice.setup do |s|
                s.server_url  = url
                s.client_name = client_name
                s.client_key   = key
            end
            @rest = Spice::Connection.new
        end
        
        def list_cookbooks
            resources = []
            @rest.cookbooks.each do |cookbook|
                resources << {:name=>cookbook.name, :latest_version=>cookbook.versions[0]}
            end
            return resources
        end

        def get_cookbook(name, version)
            if(version == nil)
                return @rest.cookbook(name)
            else
                return @rest.cookbook_version(name, version)
            end
        end

        def get_recipes(cookbook_name, cookbook_version)
            cookbook = get_cookbook(cookbook_name, cookbook_version)
            return cookbook.metadata["recipes"]
        end

        def get_environments()
            envs = @rest.environments;
            return envs
        end

        def get_environment(env_name)
            return @rest.environment(env_name);
        end

        def get_roles()
            return @rest.roles;
        end

        def get_role(role_name)
            return @rest.role(role_name);
        end

        def get_nodes()
            return @rest.nodes();
        end

        def get_node(node_name)
            return @rest.node(node_name)
        end

    end
end