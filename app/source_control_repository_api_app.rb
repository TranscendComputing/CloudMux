require 'sinatra'

class SourceControlRepositoryApiApp < ApiBase
    
    # Get a SC Repo by ID
    get '/:id' do
       repo = SourceControlRepository.where(id:params[:id]).first
        if repo.nil?
            [NOT_FOUND]
        else
            [OK, repo.to_json]
        end
    end

    # Get SC Repo for org
    get '/org/:org_id' do
        repos = SourceControlRepository.where(org_id:params[:org_id])
        response = []
        repos.each do |repo|
            response << repo.as_json
        end
        [OK, response.to_json]
    end

    # Create a SC Repo
    post '/' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else
            new_repo = SourceControlRepository.new(json_body)
            if new_repo.valid?
                new_repo.save!
                [CREATED, new_repo.to_json]
            else
                [BAD_REQUEST]
            end
        end
    end

    # Update a SC Repo
    put '/:id' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else 
            update_repo = SourceControlRepository.where(id:params[:id]).first
            if update_repo.nil?
                [NOT_FOUND]
            else
                begin
                    update_repo.update_attributes!(json_body)
                    [OK, update_repo.to_json]
                rescue => e
                    [BAD_REQUEST]
                end
            end
        end
    end

    # Delete a SC Repo
    delete '/:id' do
        repo = SourceControlRepository.where(id:params[:id]).first
        if repo.nil?
            [NOT_FOUND]
        else
            repo.delete
            [OK, {"message"=> "Source Control Repository Deleted"}.to_json]
        end
    end

end
