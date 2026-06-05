module Fb
  class Error < StandardError; end

  # Raised when a request to the Facebook Graph API fails (e.g. a non-2xx
  # response). The message contains the error returned by the API.
  class HTTPError < Error; end

  # Raised when a required configuration value (e.g. an environment
  # variable like FB_CLIENT_ID or FB_CLIENT_SECRET) is missing.
  class ConfigurationError < Error; end
end
