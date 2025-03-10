require 'net/http'
require 'json'

module Fb
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
    # @returns newly posted video id.
    # @see https://developers.facebook.com/docs/video-api/guides/crossposting
    def crosspost_video(options = {})
      params = { access_token: @access_token }
      params[:crossposted_video_id] = options[:crossposted_video_id] || ""

      request = HTTPRequest.new(path: "/#{@id}/videos", method: :post, params: params)
      request.run.body['id']
    end

    # crossposted_video_id must be provided.
    # @return True if update is successful.
    # @see https://developers.facebook.com/docs/graph-api/reference/video/#Updating
    def update_video(video_id, options = {})
      params = { access_token: @access_token }
      params[:name] = options[:name] || ""
      params[:description] = options[:description] if options[:description]
      request = HTTPRequest.new(path: "/#{video_id}", method: :post, params: params)
      request.run.body['success']
    end
  end
end
