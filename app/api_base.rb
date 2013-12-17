#
# Placeholder for commonality between API apps
#
require 'logging'

class ApiBase < Sinatra::Base
  include HttpStatusCodes
  #register Sinatra::CrossOrigin
  
  @@logger = nil

  configure :production, :development do
    enable :logging
  end

  configure :development do
    require 'awesome_print'
    base_logger = Logging.logger(STDOUT)
    Logging.logger.root.add_appenders(Logging.appenders.stdout)
    Logging.logger.root.level = :debug
  end

  disable :protection

  # capture the incoming host and port for generating complete links in actions.
  # Note: This currently isn't threadsafe, but could be made so by using thread local
  before { ServiceConfig.base_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}" }

  # make the default content type JSON. Actions that require something else can simply change it using the same call
  before { content_type 'application/json', :charset => 'utf-8' }
  
  before { headers "Access-Control-Allow-Origin" => "*" }
  #before { headers 'Access-Control-Allow-Headers' => ["Content-Type", "X-HTTP-Method-Override"] }

  #after { headers 'Access-Control-Allow-Methods' => "PUT" }
  #after { headers 'Access-Control-Allow-Headers' => ["Content-Type", "X-HTTP-Method-Override"] }
=begin
  before do
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = ['post', 'get', 'OPTIONS', 'PUT', 'delete']
    headers['Access-Control-Allow-Headers']  = ['x-http-method-override']
    headers['Access-Control-Max-Age'] = '1728000'    
  end

  after do    
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = ['post', 'get', 'OPTIONS', 'PUT', 'delete']
    headers['Access-Control-Allow-Headers']  = ['x-http-method-override']
    headers['Access-Control-Max-Age'] = '1728000'
  end
=end
  # catch errors when a find(id) fails
  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  # treat bad IDs as not found
  error BSON::InvalidObjectId do
    halt 404
  end

  options '/*' do
    response["Access-Control-Allow-Headers"] = "origin, x-requested-with, content-type, X-HTTP-Method-Override"
  end

  # initialize generic
  def initialize(app=nil)
    setup_log()
    super(app)
  end

  def setup_log
    # rack logger
    #rack_logger = Log4r::Logger.new("rack")

    # register rack logger
    #use Rack::CommonLogger, base_logger

    # app logger
    @@logger = Logging.logger[self]
  end

  def body_to_json(request)
    if(!request.content_length.nil? && request.content_length != "0")
      begin
        json_body = MultiJson.decode(request.body.read)
        return json_body
      rescue
        return nil
      end
    else
      return nil
    end
  end

  # TODO: not sure if this is required for production
  # not_found do
  #   '{"error":{"message":"Not found","validation_errors":{}}}'
  # end
end
