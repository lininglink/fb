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
        request.run_all_pages.map do |page_data|
          # Pages: a missing page token means "no access"
          Page.new symbolize_keys(page_data)
        end
      end
    end

    def businesses
      @businesses ||= begin
        params = { access_token: @access_token, fields: "name,access_token" }
        request = HTTPRequest.new path: '/me/businesses', params: params
        request.run_all_pages.map do |business_data|
          # Businesses: Graph never returns a token
          Business.new symbolize_keys(business_data).merge(access_token: @access_token)
        end
      end
    end

    private

    def symbolize_keys(options)
      options.convert_keys { |k| k.to_sym }
    end
  end
end
