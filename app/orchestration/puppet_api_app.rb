require 'sinatra'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'puppet', 'rest_client.rb')

class PuppetApiApp < ApiBase

    before do
        if(params[:account_id])
            cloud_acc = CloudAccount.find(params[:account_id]);
            puppet_config = cloud_acc.config_managers.select {|c| c["type"] == "puppet"}[0]
            if(puppet_config)
                puppet_url = puppet_config.protocol + "://" + puppet_config.host
                if(!(puppet_config.port != "" && puppet_config.port != nil && puppet_config.protocol == "https"))
                    puppet_url.concat(":" + puppet_config.port)
                end
                @puppet = Puppet::Client.new(puppet_url, puppet_config.auth_properties["foreman_user"], puppet_config.auth_properties["foreman_pass"]);
            else
                message= Error.new.extend(ErrorRepresenter)
                message.message = "Must configure a Puppet server with the cloud account."
                halt [BAD_REQUEST, message.to_json]
            end
       else
          message = Error.new.extend(ErrorRepresenter)
          message.message = "Account ID must be passed in as a parameter"
          halt [BAD_REQUEST, message.to_json]
        end
    end

    get '/agents' do
        begin
            agents = @puppet.get_agents
        rescue Excon::Errors::SocketError
            [BAD_REQUEST, {:message=>"Could not connect to Puppet Foreman."}.to_json]
        end
        if(agents)
            [OK, agents.to_json]
        else
            [BAD_REQUEST, {:message=>"Could not fetch agents/node data"}.to_json]
        end
    end

    post '/agents/find' do
        instanceData = JSON.parse(request.body.read)
        if(!instanceData || instanceData.length == 0)
            message = Error.new.extend(ErrorRepresenter)
            message.message = "Must supply ids of instances to search for"
            [BAD_REQUEST, message.to_json]
        else
            begin
                agent_ids = @puppet.find_agents(instanceData);
            rescue Excon::Errors::SocketError
                [BAD_REQUEST, {:message=>"Could not connect to Puppet Foreman."}.to_json]
            end
            [OK, agent_ids.to_json];
        end
    end

    put '/agents/:agent_id' do
        body = request.body.read
        class_list = JSON.parse(body)["puppetclass_ids"]
        begin
            response = @puppet.update_classes(params[:agent_id], class_list)
        rescue RestClient::InternalServerError
            [BAD_REQUEST, {:message=>"Internal Server Error"}.to_json]
        rescue Excon::Errors::SocketError
            [BAD_REQUEST, {:message=>"Could not connect to Puppet Foreman."}.to_json]
        end
        if(response)
            [OK, response.to_json]
        else
            [BAD_REQUEST, {:message=>"Could not update agent's classes"}.to_json]
        end
    end

    get '/classes' do
        begin
            classes = @puppet.get_classes
        rescue Excon::Errors::SocketError, Errno::EHOSTUNREACH
            [BAD_REQUEST, {:message=>"Could not connect to Puppet Foreman."}.to_json]
        end

        if(classes)
            [OK, classes.to_json]
        else
            [BAD_REQUEST, {:message=>"Could not fetch classes data"}.to_json]
        end
    end

end