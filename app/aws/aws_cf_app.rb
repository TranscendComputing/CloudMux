require 'sinatra'
require 'fog'
require 'httparty'

class AwsCloudFormationApp < ResourceApiBase
    
    before do
        if ! params[:cred_id].nil? #&& Auth.validate(params[:cred_id],"CloudFormation","action")
            cloud_cred = get_creds(params[:cred_id])
            if ! cloud_cred.nil?
                if params[:region].nil? || params[:region] == "undefined" || params[:region] == ""
                    @cf = Fog::AWS::CloudFormation.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key})
                else
                    @cf = Fog::AWS::CloudFormation.new({:aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key, :region => params[:region]})
                end
            end
        end
        halt [BAD_REQUEST, {:message=>"cred_id parameter must be specified"}.to_json] if @cf.nil?
    end

    get '/stacks' do
        begin
            response = @cf.describe_stacks.body["Stacks"]
            [OK, response.to_json]
        rescue => error
                handle_error(error)
        end
    end
    get '/stacks/:stack_name/resources' do
        begin
            stack_name = params[:stack_name]
            response = @cf.describe_stack_resources({'StackName'=>stack_name}).body["StackResources"]
            [OK, response.to_json]
        rescue => error
                handle_error(error)
        end
    end

    get '/stacks/:stack_name/events' do
        begin
            stack_name = params[:stack_name]
            response = @cf.describe_stack_events(stack_name).body["StackEvents"]
            [OK, response.to_json]
        rescue => error
                handle_error(error)
        end
    end

    get '/stacks/:stack_name/template' do
        begin
            stack_name = params[:stack_name]
            response = @cf.get_template(stack_name).body["TemplateBody"]
            [OK, response]
        rescue => error
                handle_error(error)
        end
    end

    post '/template/validate' do
        begin
            type = params[:type]

            if(type== "url" || type=="body")
                body = JSON.parse(request.body.read);
                paramName = type=="url" ? "TemplateURL" : "TemplateBody";
                data = type=="url" ? body[paramName] : body[paramName].to_json
                if(body[paramName])
                    response = @cf.validate_template({paramName=>data})
                else
                    [BAD_REQUEST, {:message=>"Must supply either Template file, body, or URL"}]
                end
            elsif(type=="file")
                file = params[:template][:tempfile].read
                response = @cf.validate_template({"TemplateBody"=> file})
                puts('')
            else
                [BAD_REQUEST, {:message=>"Must supply the type parameter"}.to_json]
            end

            if(response)
                [OK, response.data[:body].to_json]
            else
                [BAD_REQUEST, {:message => "Server error. Could not validate template"}.to_json]
            end
        rescue => error
            [BAD_REQUEST, {:message => error.to_s}.to_json]
        end
    end


end