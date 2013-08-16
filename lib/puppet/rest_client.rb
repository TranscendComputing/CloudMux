require 'rest-client'
require 'json'
require 'debugger'

class Puppet
    class RestClient
    
        def initialize(master_url, key, cert, cacert, environment="production")
            @rest = RestClient::Resource.new(
                "#{master_url}/#{environment}",
                :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(cert),
                :ssl_client_key   =>  OpenSSL::PKey::RSA.new(key),
                :ssl_ca_file      =>  OpenSSL::X509::Certificate.new(cacert),
                :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER
                )
        end
        
        def list_resources
            response = @rest.get "#{@url}/resource_types/*", {:accept => :pson}
            @resources = JSON.parse(response)
            return @resources
        end
        
        def list_class_resources
            return get_types("class")
        end 
        
        def list_module_resources
            classes = list_class_resources
            modules = []
            classes.each do |c|
                unless c["file"].match("/init.pp").nil?
                    #moduleJson = { :"name" =>c["name"]}
                    modules << c
                end
            end
            return modules
        end
        
        def list_node_resources
            get_types("node")
        end
        
        def list_facts(node)
            response = @rest.get "#{@url}/facts/#{node}", {:accept => :pson}
            return JSON.parse(response)
        end
        
        def list_all_agents
            response = @rest.get "#{@url}/facts_search/search?facts.hostname.ne=", {:accept => :pson}
            @agents = JSON.parse(response)
            return @agents
        end
        
        def search_by_facts(fact_name, fact_value)
            response = @rest.get "#{@url}/facts_search/search?facts.#{fact_name}=#{fact_value}", {:accept => :pson}
            return JSON.parse(response)
        end
        
        def describe_all_agents
            @agents ||= list_all_agents
            query = []
            @agents.each do |a|
                query << list_facts(a)
            end
            return query
        end
        
        private
        
        def get_types(type)
            @resources ||= list_resources
            types = []
            @resources.each do |res|
                if res["kind"] == type
                    types << res
                end
            end
            return types
        end
    end
end