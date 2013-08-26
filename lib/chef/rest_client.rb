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
            recipes = []
            recipes_metadata = cookbook["metadata"]["recipes"]
            cookbook["recipes"].each{|recipe|
                recipe_name = recipe["name"].chomp(".rb")
                if(recipe_name == "default")
                    recipes.unshift({"name"=>cookbook_name, "description"=>recipes_metadata[cookbook_name]});
                else
                    full_name = cookbook_name + "::" + recipe_name
                    recipes << {"name"=>full_name, "description"=>recipes_metadata[full_name]} 
                end
            }
            return recipes
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
            nodes = @rest.get("/nodes/")
            return nodes
        end

        def get_node(node_name)
            return @rest.node(node_name)
        end

        def find_node(name)
            # node = @rest.nodes(:q => "name:"+ name + " OR " +
            #     "hostname:"+ name + " OR " + 
            #     "fqdn:"+ fqdn + " OR " +  
            #     "ipaddress:"+ipaddress)
            nodes = @rest.get("/nodes/");
            if(nodes[name])
                return get_node(name)
            else
                return nil;
            end
        end

        def update_runlist(node_name, data)
            node = self.get_node(node_name)

            run_list = []
            JSON.parse(data).each{|item|
                full_name = item["type"] + "[" + item["name"] +"]"
                if(!self.verify_exists(item))
                    raise Spice::Error::NotFound, full_name + " does not exist."
                end
                run_list << full_name
            }
            node["run_list"].concat(run_list)
            result = @rest.put("/nodes/" + node_name, node);
            return result;
        end

        def verify_exists(run_list_item)
            begin
                if(run_list_item["type"] == "role")
                    self.get_role(run_list_item["name"])
                elsif(run_list_item["type"] == "recipe")
                    version = run_list_item["version"]
                    cookbook_name = run_list_item["name"].split("::")[0]
                    recipes = self.get_recipes(cookbook_name, version);
                    recipes.each{|recipe|
                        if(recipe["name"] == run_list_item["name"])
                            return true;
                        end
                    }
                    return false
                end
                return true
            rescue Spice::Error::NotFound
                return false
            end
        end
    end
end