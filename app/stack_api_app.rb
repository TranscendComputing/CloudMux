require 'sinatra'

class StackApiApp < ApiBase

    # Get a Stack by ID
    get '/:id' do
        stack = Stack.where(id:params[:id]).first
        if stack.nil?
            [NOT_FOUND]
        else
            [OK, stack.to_json]
        end
    end

    # Get Stacks for account
    get '/account/:account_id' do
        stacks = Stack.where(account_id:params[:account_id])
        response = []
        stacks.each do |stack|
            response << stack.as_json
        end
        [OK, response.to_json]
    end

    # Create a Stack
    post '/' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else
            json_body["template"] = json_body["template"].to_json
            new_stack = Stack.new(json_body)
            if new_stack.valid?
                new_stack.save!
                [CREATED, new_stack.to_json]
            else
                [BAD_REQUEST]
            end
        end
    end

    # Update a Stack
    put '/:id' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else 
            update_stack = Stack.where(id:params[:id]).first
            if update_stack.nil?
                [NOT_FOUND]
            else
                update_stack.name = json_body["name"] unless json_body["name"].nil?
                update_stack.description = json_body["description"] unless json_body["description"].nil?
                update_stack.compatible_clouds = json_body["compatible_clouds"] unless json_body["compatible_clouds"].nil?
                update_stack.template = json_body["template"].to_json unless json_body["template"].nil?
                if update_stack.valid?
                    update_stack.save!
                    [OK, update_stack.to_json]
                else
                    [BAD_REQUEST]
                end
            end
        end
    end

    # Delete a Stack
    delete '/:id' do
        stack = Stack.where(id:params[:id]).first
        if stack.nil?
            [NOT_FOUND]
        else
            stack.delete
            [OK]
        end
    end
end
