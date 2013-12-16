require 'sinatra'

class ContinuousIntegrationApiApp < ApiBase
    
    # Get a CI Server by ID
    get '/:id' do
       ci_server = ContinuousIntegrationServer.where(id:params[:id]).first
        if ci_server.nil?
            [NOT_FOUND]
        else
            [OK, ci_server.to_json]
        end
    end

    # Get CI Servers for org
    get '/org/:org_id' do
        ci_servers = ContinuousIntegrationServer.where(org_id:params[:org_id])
        response = []
        ci_servers.each do |ci_server|
            response << ci_server.as_json
        end
        [OK, response.to_json]
    end

    # Create a CI Server
    post '/' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else
            new_ci_server = ContinuousIntegrationServer.new(json_body)
            if new_ci_server.valid?
                new_ci_server.save!
                [CREATED, new_ci_server.to_json]
            else
                [BAD_REQUEST]
            end
        end
    end

    # Update a CI Server
    put '/:id' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else 
            update_ci_server = ContinuousIntegrationServer.where(id:params[:id]).first
            if update_ci_server.nil?
                [NOT_FOUND]
            else
                begin
                    update_ci_server.update_attributes!(json_body)
                    [OK, update_ci_server.to_json]
                rescue => e
                    [BAD_REQUEST]
                end
            end
        end
    end

    # Delete a CI Server
    delete '/:id' do
        ci_server = ContinuousIntegrationServer.where(id:params[:id]).first
        if ci_server.nil?
            [NOT_FOUND]
        else
            ci_server.delete
            [OK, {"message"=> "Continuous Integration Server Deleted"}.to_json]
        end
    end

end
