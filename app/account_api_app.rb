require 'sinatra'

class AccountApiApp < ApiBase
  ##~ sapi = source2swagger.namespace("accounts")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Account"] = {:id => "Account", :properties => {:id => {:type => "string"}, :org_id => {:type => "string"}, :login => {:type => "string"}, :first_name => {:type => "string"}, :last_name => {:type => "string"}}}
  ##~ a = sapi.apis.add
   
  ##~ a.set :path => "/stackplace/v1/accounts"
  ##~ a.description = "Retrieve a system account by ID"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Account"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Retrieves the public information about an account, either by the account's ID or login"  
  ##~ op.nickname = "get_account"
  ##~ op.parameters.add :name => "id", :description => "ID of the account", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"
  ##~ op.errorResponses.add :reason => "Success. Response is a JSON payload with the account's details", :code => 200
  ##~ op.errorResponses.add :reason => "Not found", :code => 404
  ##~ op.errorResponses.add :reason => "API down", :code => 500

  get '/:id.json' do
     # find by login first, then try ID, raising the standard error if not found by id
    account = Account.find_by_login(params[:id]) || Account.find(params[:id])
    account.extend(AccountSummaryRepresenter)
    account.to_json
  end
end
