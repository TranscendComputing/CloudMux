#
# Placeholder for commonality between API apps
#
class ApiBase < Sinatra::Base
  include HttpStatusCodes

  disable :protection

  # capture the incoming host and port for generating complete links in actions.
  # Note: This currently isn't threadsafe, but could be made so by using thread local
  before { ServiceConfig.base_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}" }

  # make the default content type JSON. Actions that require something else can simply change it using the same call
  before { content_type 'application/json', :charset => 'utf-8' }

  # catch errors when a find(id) fails
  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  # treat bad IDs as not found
  error BSON::InvalidObjectId do
    halt 404
  end

  # TODO: not sure if this is required for production
  # not_found do
  #   '{"error":{"message":"Not found","validation_errors":{}}}'
  # end
end
