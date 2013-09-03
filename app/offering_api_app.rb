require 'sinatra'

class OfferingApiApp < ApiBase

    # Get an Offering by ID
    get '/:id' do
       offering = Offering.where(id:params[:id]).first
        if offering.nil?
            [NOT_FOUND]
        else
            [OK, offering.to_json]
        end
    end

    # Get Offerings for account
    get '/account/:account_id' do
        offerings = Offering.where(account_id:params[:account_id])
        response = []
        offerings.each do |offering|
            response << offering.as_json
        end
        [OK, response.to_json]
    end

    # Create an Offering
    post '/' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else
        	stacks = []
        	if ! json_body["stack_ids"].nil?
        		stack_ids = json_body.delete("stack_ids")
            	stack_ids.each do |stack_id|
            		stack = Stack.where(id:stack_id).first
            		if ! stack.nil?
            			stacks << stack
            		end
            	end
            end
            new_offering = Offering.new(json_body)
            if new_offering.valid?
            	new_offering.stacks = stacks
                new_offering.save!
                [CREATED, new_offering.to_json]
            else
                [BAD_REQUEST]
            end
        end
    end

    # Update an Offering
    put '/:id' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else 
            update_offering = Offering.where(id:params[:id]).first
            if update_offering.nil?
                [NOT_FOUND]
            else
                update_offering.name = json_body["name"] unless json_body["name"].nil?
                update_offering.version = json_body["version"] unless json_body["version"].nil?
                update_offering.url = json_body["url"] unless json_body["url"].nil?
                update_offering.sku = json_body["sku"] unless json_body["sku"].nil?
                update_offering.icon = json_body["icon"] unless json_body["icon"].nil?
                update_offering.illustration = json_body["illustration"] unless json_body["illustration"].nil?
                update_offering.brief_description = json_body["brief_description"] unless json_body["brief_description"].nil?
                update_offering.detailed_description = json_body["detailed_description"] unless json_body["detailed_description"].nil?
                update_offering.eula = json_body["eula"] unless json_body["eula"].nil?
                update_offering.eula_custom = json_body["eula_custom"] unless json_body["eula_custom"].nil?
                update_offering.support = json_body["support"] unless json_body["support"].nil?
                update_offering.pricing = json_body["pricing"] unless json_body["pricing"].nil?
                update_offering.category = json_body["category"] unless json_body["category"].nil?
                if ! json_body["stack_ids"].nil?
                	update_offering.stacks = []
                	json_body["stack_ids"].each do |stack_id|
                		stack = Stack.where(id:stack_id).first
                		if ! stack.nil?
                			update_offering.stacks << stack
                		end
                	end
                end
                if update_offering.valid?
                    update_offering.save!
                    [OK, update_offering.to_json]
                else
                    [BAD_REQUEST]
                end
            end
        end
    end

    # Delete an Offering
    delete '/:id' do
        offering = Offering.where(id:params[:id]).first
        if offering.nil?
            [NOT_FOUND]
        else
            offering.delete
            [OK]
        end
    end

end
