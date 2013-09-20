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
        agents = @puppet.get_agents
        [OK, agents.to_json]
    end

    get '/classes' do
        classes = @puppet.get_classes
        [OK, classes.to_json]
    end

end