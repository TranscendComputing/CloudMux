require 'rest-client'
require 'json'
require 'debugger'

class Puppet
    class Client
    
        def initialize(url, foreman_user, foreman_password, environment="production")
            @rest = RestClient::Resource.new(
                "#{url}/",
                :user => foreman_user,
                :password => foreman_password,
                :headers => {:accept => 'version=2'}
                )
        end

        def get_agents
            agents = @rest['/api/hosts'].get
            return JSON.parse(agents);
        end

        def get_classes
            classes = @rest['/api/puppetclasses'].get :params=>{:per_page=>"100000"}
            return JSON.parse(classes);
        end
        
        
    end
end