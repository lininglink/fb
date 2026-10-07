require 'net/http'
require 'json'

module Fb
  class Video
    attr_reader :id, :title, :description, :created_time, :length, :picture, :permalink_url, :post_id

    def initialize(options = {})
      @id = options[:id]
      @title = options[:title]
      @description = options[:description]
      @created_time = options[:created_time]
      @length = options[:length]
      @picture = options[:picture]
      @permalink_url = options[:permalink_url]
      @post_id = options[:post_id]
      @access_token = options[:access_token]
    end

    # @return [Hash] the response body, with metric values in "data".
    # @see https://developers.facebook.com/docs/graph-api/reference/video/video_insights/
    def insights(options = {})
      params = { access_token: @access_token }
      request = HTTPRequest.new path: "/#{@id}/video_insights", params: options.merge(params)
      request.run.body
    end
  end
end
