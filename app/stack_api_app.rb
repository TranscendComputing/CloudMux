require 'sinatra'

class StackApiApp < ApiBase

    # Get a Stack by ID
    get '/:id.json' do
        stack = Stack.where(id:params[:id]).first
        if stack.nil?
            [NOT_FOUND]
        else
            [OK, stack.to_json]
        end
    end

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
                begin
                    update_stack.update_attributes!(json_body)
                    [OK, update_stack.to_json]
                rescue => e
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
            [OK, {"message"=> "Stack Deleted"}.to_json]
        end
    end
end
