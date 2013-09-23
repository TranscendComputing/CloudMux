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
            new_offering = Offering.new(json_body)
            if new_offering.valid?
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
                begin
                    update_offering.update_attributes!(json_body)
                    [OK, update_offering.to_json]
                rescue => e
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
            [OK, {"message"=> "Offering Deleted"}.to_json]
        end
    end

end
