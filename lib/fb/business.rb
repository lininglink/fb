require 'net/http'
require 'json'

module Fb
  class Business
    attr_reader :id, :name

    def initialize(options = {})
      @access_token = options[:access_token]
      @id = options[:id]
      @name = options[:name]
    end

    def owned_pages
      @owned_pages ||= begin
        params = { access_token: @access_token, fields: "category,name,access_token" }
        request = HTTPRequest.new path: "/#{@id}/owned_pages", params: params
        request.run.body['data'].map do |page_data|
          # unless page_data.key?("access_token")
          #   page_data.merge! access_token: @access_token
          # end
          Page.new symbolize_keys(page_data)
        end
      end
    end

    def client_pages
      @client_pages ||= begin
        params = { access_token: @access_token, fields: "category,name,access_token" }
        request = HTTPRequest.new path: "/#{@id}/client_pages", params: params
        request.run.body['data'].map do |page_data|
          # unless page_data.key?("access_token")
          #   page_data.merge! access_token: @access_token
          # end
          Page.new symbolize_keys(page_data)
        end
      end
    end

    private

    def symbolize_keys(options)
      options.convert_keys { |k| k.to_sym }
    end
  end
end
