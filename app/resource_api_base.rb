class ResourceApiBase < ApiBase
  # Long name for service representing this resource (e.g. Auto Scale, etc.)
  @service_long_name = 'undefined'

  # Cloud implementation class (typically Fog::??)
  @service_class = Object

  def can_access_service(params)
    service = nil
    cred_id = params[:cred_id]
    region = params[:region]
    provider = params[:provider]
    service_type = params[:service_type]
    if !cred_id.nil? && Auth.validate(cred_id, @service_long_name, 'action')
      cloud_cred = get_creds(cred_id)
      if !cloud_cred.nil?
        args = determine_service_args(region, provider, service_type, cloud_cred)
        service = @service_class.new(args)
        halt [BAD_REQUEST] if service.nil?
      else
        halt [NOT_FOUND, 'Credentials not found.']
      end
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = 'Cannot access this service under current policy.'
      halt [NOT_AUTHORIZED, message.to_json]
    end
    service
  end

  def determine_service_args(region, provider, service_type, cloud_cred)
    if provider == 'aws'
      args = { :aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key }
      args[:region] = region if region != 'undefined' && region != ''
    elsif provider == 'openstack'
      args = cloud_cred.cloud_attributes.merge(:provider => 'openstack')
    elsif provider == 'topstack'
      begin
        # Find service endpoint
        endpoint = cloud_cred.cloud_account.cloud_services.where('service_type' => service_type).first
        halt [BAD_REQUEST] if endpoint.nil?
        args = { :aws_access_key_id => cloud_cred.access_key, :aws_secret_access_key => cloud_cred.secret_key }
        args.merge!(:host => endpoint[:host], :port => endpoint[:port], :path => endpoint[:path], :scheme => endpoint[:protocol])
      rescue Fog::Errors::NotFound => error
        halt [NOT_FOUND, error.to_s]
      end
    end
    args
  end

  def can_create_instance(params)
    unless Auth.validate(params['cred_id'], @service_long_name, params['action'], params['options'])
      message = Error.new.extend(ErrorRepresenter)
      if params['action'] == 'create_autoscale'
        message.message = 'Cannot create an AutoScale group of that size'
      elsif params['action'] == 'use_image'
        message.message = 'The image selected unavailable under current policy'
      else
        message.message = 'Cannot create anymore instances of this type under current policy'
      end
      halt [BAD_REQUEST, message.to_json]
    end
  end

  # Changes the request to a usable format for processiong
  def body_to_json(request)
    if !request.content_length.nil? && request.content_length != '0'
      return MultiJson.decode(request.body.read)
    else
      return nil
    end
  end

  # Takes the request body and checks for valid information. Stops the request if the body is nil.
  # Can take in additional parameters as a hash and checks if the request body has the information specified.
  def body_to_json_or_die(request)
    json_body = body_to_json(request['body'])
    if json_body.nil?
      halt [BAD_REQUEST]
    elsif request.length > 1
      request['args'].each do |condition|
        halt [BAD_REQUEST] if json_body[condition].nil?
      end
    end
    json_body
  end

  def get_creds(cred_id)
    Account.find_cloud_credential(cred_id)
  end

  # checks for special cases before handing off to handle_error
  def pre_handle_error(service, error)
    if error.is_a?(TypeError)
      service.instance_variable_get('@aws_session_token').nil? ? handle_error(error, 'The credentials supplied are invalid') : handle_error(error)
    else
      handle_error(error)
    end
  end

  def handle_error(error, custom_type_error = nil)
    case error
    when TypeError
      message = custom_type_error.nil? ? error.to_s  : custom_type_error
      [NOT_ACCEPTABLE, message]
    when Fog::AWS::IAM::EntityAlreadyExists
      [NOT_ACCEPTABLE, error.message]
    when Fog::AWS::IAM::Error
      [NOT_FOUND, error.message.split(' => ')[1]]
    when Fog::Compute::AWS::Error
      [NOT_ACCEPTABLE, error.message.split(' => ')[1]]
    when Fog::Compute::OpenStack::NotFound
      [NOT_FOUND, 'OpenStack resource not found.']
    when Fog::Identity::OpenStack::NotFound
      [NOT_AUTHORIZED, 'You are not authorized for this action.']
    when Fog::Network::OpenStack::NotFound
      [NOT_FOUND, 'NeutronError: Router has no interface on subnet.']
    when Excon::Errors::Conflict
      begin
        response_body = JSON.parse(error.response.body)
        message = response_body['conflictingRequest']['message']
        message = response_body['error']['message'] if message.nil? || message.empty?
      rescue JSON::ParserError
        response_body = Nokogiri::XML(error.response.body)
        message = response_body.css('Message').text
        message = error.response.body.to_s.gsub('\n', ' ') if message.nil? || message.empty?
      rescue
        message = error.response.body.to_s.gsub('\n', ' ')
      end
      [BAD_REQUEST, message]
    when Excon::Errors::BadRequest
      begin
        response_body = JSON.parse(error.response.body)
        message = response_body['badRequest']['message']
        message = response_body['error']['message'] if message.nil? || message.empty?
      rescue JSON::ParserError
        response_body = Nokogiri::XML(error.response.body)
        message = response_body.css('Message').text
        message = error.response.body.to_s.gsub('\n', ' ') if message.nil? || message.empty?
      rescue
        message = error.response.body.to_s.gsub('\n', ' ')
      end
      [BAD_REQUEST, message]
    when Excon::Errors::InternalServerError
      response_body = Nokogiri::XML(error.response.body)
      if response_body.css('Message').empty?
        message = error.response.body
      else
        message = response_body.css('Message').text
      end
      [ERROR, message]
    when Excon::Errors::NotFound
      begin
        response_body = Nokogiri::XML(error.response.body)
        message = response_body.css('Message').text
      rescue
        message = error.to_s
      end
      [NOT_FOUND, message]
    when Excon::Errors::Forbidden
      begin
        response_body = JSON.parse(error.response.body)
        message = response_body['forbidden']['message']
        message = response_body['error']['message'] if message.nil? || message.empty?
      rescue JSON::ParserError
        response_body = Nokogiri::XML(error.response.body)
        message = response_body.css('Message').text
        message = error.response.body.to_s.gsub('\n', ' ') if message.nil? || message.empty?
      rescue
        message = error.response.body.to_s.gsub('\n', ' ')
      end
      [FORBIDDEN, message]
    when Excon::Errors::Timeout
      message = 'Read Timeout Reached'
      [TIMEOUT, message]
    when Net::HTTPServerException
      message = JSON.parse(error.response.body)['error'][0]
      [ERROR, message]
    when RuntimeError, ArgumentError, Fog::Compute::VcloudDirector::TaskError
      #weird error format coming back from fog
      [BAD_REQUEST, error.message.split('message=>')[1]]
    when RuntimeError, ArgumentError, Fog::Compute::VcloudDirector::BadRequest
      [BAD_REQUEST, error.to_s]
    when  Fog::AWS::RDS::NotFound, Fog::AWS::Elasticache::NotFound, Fog::Errors::NotFound
      [NOT_FOUND, error.to_s]
    when Fog::JSON::DecodeError
      # Work around for bug in Grizzly. Needs to be removed if ever fixed.
      return
    else
      [BAD_REQUEST, error.to_s]
    end
  end
end
