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
    get '/org/:org_id' do
        portfolios = Portfolio.where(org_id:params[:org_id])
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
            new_portfolio = Portfolio.new(json_body)
            if new_portfolio.valid?
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
                begin
                    update_portfolio.update_attributes!(json_body)
                    [OK, update_portfolio.to_json]
                rescue => e
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
            [OK, {"message"=> "Portfolio Deleted"}.to_json]
        end
    end

end
