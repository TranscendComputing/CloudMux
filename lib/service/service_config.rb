#
# Captures service-level configuration settings
#
class ServiceConfig
  class << self
    # the host to associate with this service. Set from ApiBase
    attr_accessor :base_url
  end
end
