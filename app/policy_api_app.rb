require 'sinatra'
require 'debugger'

class PolicyApiApp < ApiBase
    
    # Fetch a group's details
    get '/' do
        debugger
        result = Auth.validate("myWho","myWhere","myAction")
        [OK, result.to_json]
    end

end