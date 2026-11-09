require 'net/http'
require 'json'

module Fb
  class User
    def initialize(options = {})
      @access_token = options[:access_token]
    end

    def email
      @email ||= begin
        request = HTTPRequest.new path: '/me', params: {
          fields: :email,
          access_token: @access_token
        }
        request.run.body['email']
      end
    end

    def revoke_permissions
      params = { access_token: @access_token }
      request = HTTPRequest.new path: '/me/permissions', params: params, method: :delete
      request.run.body['success']
    end

    def pages
      @pages ||= begin
        params = { access_token: @access_token, fields: "category,name,access_token" }
        request = HTTPRequest.new path: '/me/accounts', params: params
        request.run.body['data'].map do |page_data|
          # unless page_data.key?("access_token")
          #   page_data.merge! access_token: @access_token
          # end
          Page.new symbolize_keys(page_data)
        end
      end
    end

    def businesses
      @businesses ||= begin
        params = { access_token: @access_token, fields: "name,access_token" }
        request = HTTPRequest.new path: '/me/businesses', params: params
        request.run.body['data'].map do |business_data|
          unless business_data.key?("access_token")
            business_data.merge! access_token: @access_token
          end
          Business.new symbolize_keys(business_data)
        end
      end
    end

    private

    def symbolize_keys(options)
      options.convert_keys { |k| k.to_sym }
    end
  end
end
