require 'sinatra'

class TutorialStateApiApp < ApiBase
	##~ sapi = source2swagger.namespace("tutorial_states")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  ##~ a = sapi.apis.add   
  ##~ a.set :path => "/api/v1/tutorial_states"
  ##~ a.description = "Manage tutorial states"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Get current tutorial progress for the current user"  
  ##~ op.parameters.add :name => "page", :description => "The page number of the query. Defaults to 1 if not provided", :dataType => "integer", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "per_page", :description => "Result set page size", :dataType => "integer", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.errorResponses.add :reason => "Query successful", :code => 200
  ##~ op.errorResponses.add :reason => "API down", :code => 500

  get '/' do
  	if params[:account_id].nil?
  		message = Error.new.extend(ErrorRepresenter)
  		message.message = "Must provide account id with request"
  		[BAD_REQUEST, message.to_json]
  	else
  		conditions = { }
    	conditions[:account_id] = params[:account_id]
    	tutorial_state = TutorialState.all.where(conditions).last.extend(TutorialStateRepresenter)
  		[OK, tutorial_state.to_json]
  	end
  end

  post '/' do
  	if params[:account_id].nil?
  		message = Error.new.extend(ErrorRepresenter)
  		message.message = "Must provide account id with request"
  		[BAD_REQUEST, message.to_json]
  	else
      conditions = { }
      conditions[:account_id] = params[:account_id]
      tutorial_state = TutorialState.all.where(conditions).last.extend(TutorialStateRepresenter)

      if tutorial_state.nil?
        tutorial_state = TutorialState.new.extend(TutorialStateRepresenter)
      end
        
      tutorial_state.from_json(params.to_json)
			tutorial_state.save!
			[OK, tutorial_state.to_json]
  	end
  end
end