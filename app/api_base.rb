#
# Placeholder for commonality between API apps
#
require 'logging'

class ApiBase < Sinatra::Base
  include HttpStatusCodes
  
  @@logger = nil

  configure :production, :development do
    enable :logging
  end

  configure :development do
    require 'awesome_print'
    Logging.logger(STDOUT)
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
    # app logger
    @@logger = Logging.logger[self]
  end

  def body_to_json(request)
    return if (request.content_length.nil? or request.content_length == "0")
    MultiJson.decode(request.body.read) rescue nil
  end

  def body_to_yaml(request)
    return if (request.content_length.nil? or request.content_length == "0")
    YAML.load(request.body.read) rescue nil
  end
end
