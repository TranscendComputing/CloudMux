require 'rest-client'
require 'json'

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
            response = JSON.parse(agents);
            result = {};
            response.each { |host|
                name = host["host"]["name"]
                id = host["host"]["id"];
                result[name] = id;
            }
            return result;
        end

        def get_agent_classes(host_id)
            class_ids = @rest['api/hosts/' + host_id + "/puppetclass_ids"].get
            return JSON.parse(class_ids);
        end

        def update_classes(host_id, class_list)
            class_ids = get_agent_classes(host_id).to_set.map!(&:to_s)

            toAdd = (class_list.to_set - class_ids).to_a
            added = [];
            toAdd.each{|id|
                @rest['/api/hosts/'+host_id+"/puppetclass_ids"].post :puppetclass_id=>id
                added << id
            }
            #Body doesn't seem to be right format for some reason?  Have to iteratively update classes using /api/hosts/:host_id/puppetclass?puppetclass_id=## API
            # class_ids = get_agent_classes(host_id).to_set
            # class_ids.map!(&:to_s)
            # class_ids.merge(class_list)
            # putBody = {:puppetclass_ids => class_ids.to_a}
            #response = @rest['api/hosts/'+host_id].put putBody, :content_type => 'application/json', :accept=>"version=2"

            return {:message=>"Added classes to agent configuration"}
        end

        def get_facts
            facts = @rest['/api/fact_values'].get :params=>{:per_page=>"100000"}
            return JSON.parse(facts);
        end

        def flatten_facts(factsList)
            flattened = {};
            factsList.each{|host, facts|
                flattened[facts["ipaddress"]] = host
                flattened[facts["hostname"]] = host
            }
            return flattened;
        end

        def get_classes
            classes = @rest['/api/puppetclasses'].get :params=>{:per_page=>"100000"}
            return JSON.parse(classes);
        end

        def find_agents(instances)
            result = []
            agents = get_agents
            facts = flatten_facts(get_facts)

            instances.each_with_index{|instanceInfo, index|
                name = instanceInfo["name"]
                ip_addrs = instanceInfo["ip_addresses"]

                agentId = agents[name];
                if(!agentId && ip_addrs)
                    agent = facts[name]
                    if(!agent)
                        ip_addrs.each{|addr|
                            agent = facts[addr]
                        }
                    end
                    agentId = agents[agent]
                end
                if(agentId)
                    result << {:foreman_id => agentId}
                else
                    result << {}
                end
            }
            return result;
        end
        
        
    end
end
