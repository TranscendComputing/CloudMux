require 'sinatra'
require 'fog'
require 'net/http'

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
      pre_handle_error(@cf, error)
    end
  end

  post '/stacks' do
    options = params["RequestParams"]
    stack_name = options.delete("StackName")
    # XXX - Why t? Where is it used?
    t =  JSON.parse(options['TemplateBody'])
    result = @cf.create_stack(stack_name, options)
    [OK, result.to_json]
  end

  delete '/stacks/:stack_name' do
    result = @cf.delete_stack(params[:stack_name])
    [OK, result.to_json]
  end
  
  put '/stacks/:stack_name' do
    result = @cf.update_stack(params[:stack_name], params["RequestParams"])
    [OK, result.to_json]
  end

  get '/stacks/:stack_name/resources' do
    response = @cf.describe_stack_resources({
        'StackName'=> params[:stack_name]
    }).body["StackResources"]
    [OK, response.to_json]
  end

  get '/stacks/:stack_name/events' do
    stack_name = params[:stack_name]
    response = @cf.describe_stack_events(stack_name).body["StackEvents"]
    [OK, response.to_json]
  end

  get '/stacks/:stack_name/template' do
    response = @cf.get_template(params[:stack_name]).body["TemplateBody"]
    [OK, response]
  end

  post '/template/validate' do
    halt [BAD_REQUEST] unless params[:type]
    
    case params[:type]
    when 'url','body'
      body = JSON.parse(request.body.read)
      paramName = type == "url" ? "TemplateURL" : "TemplateBody"
      data = type == "url" ? body[paramName] : body[paramName].to_json

      if body[paramName]
        result = @cf.validate_template({paramName=>data}).data[:body]
        response = {"ValidationResult" => result};
      else
        templateBody = body.to_json

        if templateBody.size < 20 # Require at least 20 chars to be a reasonable template
          halt [BAD_REQUEST, "Must supply either Template file, body, or URL"]
        end

        result = @cf.validate_template({paramName=>templateBody}).data[:body]
        response = {"ValidationResult" => result, "TemplateBody" => body };
      end
    when 'file'
      file = params[:template][:tempfile].read
      result = @cf.validate_template({"TemplateBody"=> file}).data[:body]
      response = {"TemplateBody"=> JSON.parse(file), "ValidationResult" => result}
    else
      halt [BAD_REQUEST, "Invalid 'type' parameter"]
    end

    unless response["ValidationResult"]
      raise RuntimeError, 'Server error. Could not validate template'
    end

    [OK, response.to_json]
  end
end
