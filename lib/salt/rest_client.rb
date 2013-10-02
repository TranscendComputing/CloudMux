require 'rest-client'
require 'json'
require 'debugger'

class Salt
    class Client
    
        def initialize(url, user, password)
            login_response = RestClient.post(url+"/login", {:username=>user, :password=>password, :eauth=>"pam"})
            auth_token = JSON.parse(login_response)["return"][0]["token"]
            @rest = RestClient::Resource.new(
                "#{url}/",
                :headers => {:accept => "application/json", "X-Auth-Token"=>auth_token}
                )
        end

        def get_minions
            agents = @rest['/minions'].get
            response = JSON.parse(agents)["return"][0];
            return response;
        end
        
        def get_states
            response = @rest['/'].post({:client=>"local",:tgt=>"*",:fun=>"cp.list_states"})
            states = JSON.parse(response)["return"][0]
            return states[states.keys[0]];
        end

        def flatten_grains(grainsList)
            flattened = {};
            grainsList.each{|minion, grains|
                #flattened[grains["ipaddress"]] = minion
                flattened[grains["host"]] = minion
                grains["ipv4"].each{|ip|
                    if(!ip.include?("127.0"))
                        flattened[ip] = minion;
                    end
                }
            }
            return flattened;
        end
        def find_minions(instances)
            result = []
            minions = get_minions
            grains = flatten_grains(minions)

            instances.each_with_index{|instanceInfo, index|
                name = instanceInfo["name"]
                ip_addrs = instanceInfo["ip_addresses"]

                minionInfo = minions[name];
                if(!minionInfo && ip_addrs)
                    minionInfo = grains[name]
                    if(!minionInfo)
                        ip_addrs.each{|addr|
                            minionInfo = grains[addr]
                            break
                        }
                    end
                end

                if(minionInfo)
                    result << {name => minionInfo["id"]}
                else
                    result << {}
                end
            }
            return result;
        end
    end
end