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
    attr_accessor :client_id, :client_secret, :log_level

    def initialize
      @client_id = ENV['FB_CLIENT_ID']
      @client_secret = ENV['FB_CLIENT_SECRET']
      @log_level = ENV['FB_LOG_LEVEL']
    end

    def developing?
      %w(devel).include? log_level.to_s
    end
  end
end
