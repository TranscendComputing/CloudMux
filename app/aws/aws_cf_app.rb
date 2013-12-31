require 'sinatra'
require 'fog'
require 'net/http'

require File.join(File.dirname(__FILE__),'..','..','lib','scheduler.rb')

class AwsCloudFormationApp < ResourceApiBase
    
    before do
        params["provider"] = "aws"
        @service_long_name = "CloudFormation"
        @service_class = Fog::AWS::CloudFormation
        @cf = can_access_service(params)    
    end

    get '/stacks' do
        begin
            result = @cf.list_stacks
            response = result.body["StackSummaries"]
            [OK, response.to_json]
        rescue => error
                handle_error(error)
        end
    end

    post '/stacks' do
        #"{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Descr iption\":\"New template created in StackStudio.\",\"Parameters\":{},\"Mappings\":{},\"Resources\":{\"AnsibleInstance\":{\"Type\":\"AWS::EC2::Instance\",\"Properties\":{\"AvailabilityZone\":\"us-east-1a\",\"ImageId\":\"ami-1624987f\",\"Tenancy\":\"default\"}}},\"Outputs\":{}}"
        begin 
            options = params["RequestParams"]
            stack_name = options.delete("StackName")
            t =  JSON.parse(options['TemplateBody'])
            result = @cf.create_stack(stack_name, options)
            #t.Resources.each_pair do |name,r|
            #  if name.slice(0,15) == "AnsibleInstance"
            #    # Queue Ansible
            #    print "here\n\n\n"
            #  end
            #end
            [OK, result.to_json]
        rescue => error
            [BAD_REQUEST, {:message => error.to_s}.to_json]
        end
    end

    delete '/stacks/:stack_name' do
        begin 
            stack_name = params[:stack_name]
            result = @cf.delete_stack(stack_name)
            [OK, result.to_json]
        rescue => error
            [BAD_REQUEST, {:message => error.to_s}.to_json]
        end
    end
    
    put '/stacks/:stack_name' do
        begin
            stack_name = params[:stack_name]
            options = params["RequestParams"]
            result = @cf.update_stack(stack_name, options)
            [OK, result.to_json]
        rescue => error
            [BAD_REQUEST, {:message => error.to_s}.to_json]
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
            if type== "url" || type=="body"
                body = JSON.parse(request.body.read);
                paramName = type=="url" ? "TemplateURL" : "TemplateBody";
                data = type=="url" ? body[paramName] : body[paramName].to_json
                if body[paramName]
                    result = @cf.validate_template({paramName=>data}).data[:body]
                    response = {"ValidationResult" => result};
                else
                    templateBody = body.to_json
                    if templateBody.size < 20 # Require at least 20 chars to be a reasonable template
                        [BAD_REQUEST, {:message=>"Must supply either Template file, body, or URL"}]
                    end
                    result = @cf.validate_template({paramName=>templateBody}).data[:body]
                    response = {"ValidationResult" => result, "TemplateBody" => body };
                end
            elsif type=="file"
                file = params[:template][:tempfile].read
                result = @cf.validate_template({"TemplateBody"=> file}).data[:body]
                response = {"TemplateBody"=> JSON.parse(file), "ValidationResult" => result}
            else
                [BAD_REQUEST, {:message=>"Must supply the type parameter"}.to_json]
            end
            if response["ValidationResult"]
                [OK, response.to_json]
            else
                [BAD_REQUEST, {:message => "Server error. Could not validate template"}.to_json]
            end
        rescue => error
            [BAD_REQUEST, {:message => error.to_s}.to_json]
        end
    end


end
