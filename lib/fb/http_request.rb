module Fb
  class HTTPError < StandardError; end

  class HTTPRequest
    def initialize(options = {})
      @method = options.fetch :method, :get
      @expected_response = options.fetch :expected_response, Net::HTTPSuccess
      @host = options.fetch :host, 'graph.facebook.com'
      @path = options[:path]
      @params = options.fetch :params, {}
    end

    # Callback invoked with the response object on a successful response. Defaults to a noop.
    # The callback invoked with two parameters: the HTTPRequest object
    # and the Net::HTTP response object.
    @@on_response = lambda {|_, _|}

    class << self

      # Reader for @@on_response
      def on_response
        @@on_response
      end

      # Writer for @@on_response
      def on_response=(callback)
        @@on_response = callback
      end
    end

    # Sends the request and returns the response with the body parsed from JSON.
    # @return [Net::HTTPResponse] if the request succeeds.
    # @raise [Fb::HTTPError] if the request fails.
    def run
      if response.is_a? @expected_response
        self.class.on_response.call(self, response)
        response.tap do
          parse_response!
        end
      else
        raise HTTPError.new(error_message)
      end
    end

    # @return [String] the request URL.
    def url
      uri.to_s
    end

    # @return [Hash] rate limit status in the response header.
    def rate_limiting_header
      usage = response.to_hash['x-app-usage']
      JSON usage[0] if usage
    end

    private

    # @return [URI::HTTPS] the (memoized) URI of the request.
    def uri
      @uri ||= URI::HTTPS.build host: @host, path: @path, query: query
    end

    def query
      URI.encode_www_form @params
    end

    # @return [Net::HTTPRequest] the full HTTP request object.
    def http_request
      net_http_class = Object.const_get "Net::HTTP::#{@method.capitalize}"
      @http_request ||= net_http_class.new uri.request_uri
    end

    def as_curl
      curl = "curl -X #{http_request.method} \"#{url}\""
      http_request.each_header do |k, v|
        curl += %Q{ -H "#{k}: #{v}"}
      end
      curl
    end

    # Run the request and memoize the response or the server error received.
    def response
      @response ||= Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        curl_request = as_curl
        print "#{curl_request}\n" if Fb.configuration.developing?
        http.request http_request
      end
    end

    # Replaces the body of the response with the parsed version of the body,
    # according to the format specified in the HTTPRequest.
    def parse_response!
      if response.body
        response.body = JSON response.body
      end
    end

    def error_message
      JSON(response.body)['error']['message']
    end
  end
end
