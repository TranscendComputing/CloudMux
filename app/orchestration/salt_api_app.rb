require 'sinatra'
require 'debugger'
require 'json'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'salt', 'rest_client.rb')

class SaltApiApp < ApiBase

    before do
        if(params[:account_id])
            cloud_acc = CloudAccount.find(params[:account_id]);
            salt_config = cloud_acc.config_managers.select {|c| c["type"] == "salt"}[0]
            if(salt_config)
                salt_url = salt_config.protocol + "://" + salt_config.host + ":" + salt_config.port;
                @salt = Salt::Client.new(salt_url, salt_config.auth_properties["salt_user"], salt_config.auth_properties["salt_pass"]);
            else
                message= Error.new.extend(ErrorRepresenter)
                message.message = "Must configure a Salt server with the cloud account."
                halt [BAD_REQUEST, message.to_json]
            end
       else
          message = Error.new.extend(ErrorRepresenter)
          message.message = "Account ID must be passed in as a parameter"
          halt [BAD_REQUEST, message.to_json]
        end
    end

    get '/minions' do
        begin
            result = @salt.get_minions
            [OK, result.to_json]
        rescue RestClient::Unauthorized
            [UNAUTHORIZED, {:message => "Invalid Salt user/password combination."}];
        rescue Errno::ECONNREFUSED
            [BAD_REQUEST, {:message => "Connection was refused"}]
        end
    end
    post '/minions/find' do
        begin
            instanceData = JSON.parse(request.body.read)
            if(!instanceData || instanceData.length == 0)
                message = Error.new.extend(ErrorRepresenter)
                message.message = "Must supply ids of instances to search for"
                [BAD_REQUEST, message.to_json]
            else
                minions = @salt.find_minions(instanceData);
                [OK, minions.to_json];
            end
        rescue RestClient::Unauthorized
            [UNAUTHORIZED, {:message => "Invalid Salt user/password combination."}];
        rescue Errno::ECONNREFUSED
            [BAD_REQUEST, {:message => "Connection was refused"}]
        end
    end

    put '/minions/:minion_name' do
        begin

            body = request.body.read
            state_list = JSON.parse(body)["states"]
            @salt.run_states(params[:minion_name], state_list);
        rescue RestClient::Unauthorized
            [UNAUTHORIZED, {:message => "Invalid Salt user/password combination."}];
        rescue Errno::ECONNREFUSED
            [BAD_REQUEST, {:message => "Connection was refused"}]
        end
    end

    get '/states' do
        begin
            result = @salt.get_states
            [OK, result.to_json]
        rescue RestClient::Unauthorized
            [UNAUTHORIZED, {:message => "Invalid Salt user/password combination."}];
        rescue Errno::ECONNREFUSED
            [BAD_REQUEST, {:message => "Connection was refused"}]
        end
    end
    
end