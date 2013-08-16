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
                resources << JSON.parse(cookbook.to_json)
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





    end
end