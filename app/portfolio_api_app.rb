require 'sinatra'

class PortfolioApiApp < ApiBase
    
    # Get a Portfolio by ID
    get '/:id' do
       portfolio = Portfolio.where(id:params[:id]).first
        if portfolio.nil?
            [NOT_FOUND]
        else
            [OK, portfolio.to_json]
        end
    end

    # Get Portfolios for group
    get '/group/:group_id' do
        portfolios = Portfolio.where(group_id:params[:group_id])
        response = []
        portfolios.each do |portfolio|
            response << portfolio.as_json
        end
        [OK, response.to_json]
    end

    # Create a Portfolio
    post '/' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else
        	offerings = []
        	if ! json_body["offering_ids"].nil?
        		offering_ids = json_body.delete("offering_ids")
            	offering_ids.each do |offering_id|
            		offering = Offering.where(id:offering_id).first
            		if ! offering.nil?
            			offerings << offering
            		end
            	end
            end
            new_portfolio = Portfolio.new(json_body)
            if new_portfolio.valid?
            	new_portfolio.offerings = offerings
                new_portfolio.save!
                [CREATED, new_portfolio.to_json]
            else
                [BAD_REQUEST]
            end
        end
    end

    # Update a Portfolio
    put '/:id' do
        json_body = body_to_json(request)
        if json_body.nil?
            [BAD_REQUEST]
        else 
            update_portfolio = Portfolio.where(id:params[:id]).first
            if update_portfolio.nil?
                [NOT_FOUND]
            else
                update_portfolio.name = json_body["name"] unless json_body["name"].nil?
                update_portfolio.description = json_body["description"] unless json_body["description"].nil?
                update_portfolio.version = json_body["version"] unless json_body["version"].nil?
                if ! json_body["offering_ids"].nil?
                	update_portfolio.offerings = []
                	json_body["offering_ids"].each do |offering_id|
                		offering = Offering.where(id:offering_id).first
                		if ! offering.nil?
                			update_portfolio.offerings << offering
                		end
                	end
                end
                if update_portfolio.valid?
                    update_portfolio.save!
                    [OK, update_portfolio.to_json]
                else
                    [BAD_REQUEST]
                end
            end
        end
    end

    # Delete a Portfolio
    delete '/:id' do
        portfolio = Portfolio.where(id:params[:id]).first
        if portfolio.nil?
            [NOT_FOUND]
        else
            portfolio.delete
            [OK]
        end
    end

end
