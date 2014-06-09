require 'sinatra'

class AssemblyApiApp < ApiBase

    get '/' do
        assemblies = Assembly.all.entries
        [OK, assemblies.to_json]
    end
    #Get assembly by ID
    get '/:id' do
        assembly = Assembly.where(id:params[:id]).first
        if(assembly.nil?)
            [NOT_FOUND, {:message=>"Could not find assembly."}.to_json]
        else
            [OK, assembly.to_json]
        end
    end

    #Create new assembly
    post '/' do
        data = body_to_json(request)
        if(data.nil?)
            error = Error.new.extend(ErrorRepresenter)
            error.message = "Must give attributes for new assembly."
            [BAD_REQUEST, error.to_json]
        else
            assembly = Assembly.new(data);
            assembly.save!
            [OK, assembly.to_json]
        end
    end

    #Update assembly
    put '/:id' do
        data = body_to_json(request)
        if(data.nil?)
            error=Error.new.extend(ErrorRepresenter)
            error.message = "Must give attributes to update new assembly"
            [BAD_REQUEST, error.to_json]
        else
            assembly=Assembly.find(params[:id])
            assembly.update_attributes!(data);
            [OK, assembly.to_json]
        end
    end

    #Delete assembly
    delete '/:id' do
        assembly = Assembly.where(id:params[:id]).first
        if(assembly.nil?)
            error = Error.new.extend(ErrorRepresenter)
            error.message = "Could not find assembly."
            [NOT_FOUND, error.to_json]
        else
            assembly.delete
            [OK, {:message=>"Sucessfully deleted assembly."}.to_json]
        end
    end


end
