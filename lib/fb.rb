# frozen_string_literal: true

require_relative "fb/version"

require 'net/http'
require 'json'

require_relative "fb/config"
require_relative "fb/http_request"

module Fb
  class Error < StandardError; end

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

    def symbolize_keys(hash)
      {}.tap do |new_hash|
        hash.each_key {|key| new_hash[key.to_sym] = hash[key] }
      end
    end
  end

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

    def symbolize_keys(hash)
      {}.tap do |new_hash|
        hash.each_key {|key| new_hash[key.to_sym] = hash[key] }
      end
    end
  end

  class Page
    attr_reader :id, :name, :category

    def initialize(options = {})
      @id = options[:id]
      @name = options[:name]
      @category = options[:category]
      @access_token = options[:access_token]
    end

    def thumbnail_url
      "https://graph.facebook.com/#{@id}/picture?width=240&height=240"
    end

    # # For test the page token - temporary code
    # def feed
    #   params = { access_token: @access_token }
    #   request = HTTPRequest.new(path: "/#{@id}/feed", params: params)
    #   request.run.body['data']
    # end

    # Either link or message must be supplied.
    # https://developers.facebook.com/docs/graph-api/reference/v21.0/page/feed#publish
    def publish(options = {})
      params = { access_token: @access_token }
      params[:link] = options[:link] if options[:link]
      params[:message] = options[:message] if options[:message]
      request = HTTPRequest.new(path: "/#{@id}/feed", method: :post, params: params)
      request.run.body['id']
    end

    # crossposted_video_id must be provided.
    # @see https://developers.facebook.com/docs/video-api/guides/crossposting
    def crosspost_video(options = {})
      params = { access_token: @access_token }
      params[:crossposted_video_id] = options[:crossposted_video_id] || ""
      # params[:message] = options[:message] if options[:message]
      request = HTTPRequest.new(path: "/#{@id}/videos", method: :post, params: params)
      request.run.body['id']
    end
  end
end
