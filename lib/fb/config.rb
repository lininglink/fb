module Fb
  module Config
    def configure
      yield configuration if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  extend Config

  class Configuration
    attr_writer :client_id, :client_secret
    attr_accessor :log_level

    def initialize
      @client_id = ENV['FB_CLIENT_ID']
      @client_secret = ENV['FB_CLIENT_SECRET']
      @log_level = ENV['FB_LOG_LEVEL']
    end

    def client_id
      @client_id or missing!('FB_CLIENT_ID', 'client_id')
    end

    def client_secret
      @client_secret or missing!('FB_CLIENT_SECRET', 'client_secret')
    end

    def developing?
      %w(devel).include? log_level.to_s
    end

    private

    def missing!(env_var, attr)
      raise ConfigurationError,
        "#{env_var} is not set. Set the #{env_var} environment variable " \
        "or assign it via Fb.configure { |c| c.#{attr} = ... }."
    end
  end
end
