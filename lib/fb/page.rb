require 'net/http'
require 'json'

module Fb
  class Page
    attr_reader :id, :name, :category, :business

    def initialize(options = {})
      @id = options[:id]
      @name = options[:name]
      @category = options[:category]
      # The owning business, e.g. { id: "293992012345678", name: "Lining Link LLC" }
      @business = options[:business]
      @access_token = options[:access_token]
    end

    def thumbnail_url
      "https://graph.facebook.com/#{@id}/picture?width=240&height=240"
    end

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

    # # For test the page token - temporary code
    # def feed
    #   params = { access_token: @access_token }
    #   request = HTTPRequest.new(path: "/#{@id}/feed", params: params)
    #   request.run.body['data']
    # end

    # False for a page listed through a business when the user has no role on
    # that page, or did not grant it to the app.
    def access_token?
      !@access_token.to_s.empty?
    end

    def with_page_access_token
      @access_token = page_access_token
      self
    end

    def insights(options = {})
      options = default_options.merge options

      params = { access_token: @access_token }
      request = HTTPRequest.new path: "/#{@id}/insights", params: options.merge(params)
      request.run.body
    end

    # Videos uploaded to the page, most recent first.
    # Pass limit:, since: or until: to narrow them down.
    # @see https://developers.facebook.com/docs/graph-api/reference/page/videos/
    def videos(options = {})
      params = { fields: "title,description,created_time,length,picture,permalink_url,post_id" }.merge(options)
      params[:access_token] = @access_token
      request = HTTPRequest.new path: "/#{@id}/videos", params: params
      request.run.body['data'].map do |video_data|
        Video.new symbolize_keys(video_data).merge(access_token: @access_token)
      end
    end

    private

    def symbolize_keys(options)
      options.convert_keys { |k| k.to_sym }
    end

    def page_access_token
      params = { fields: "access_token", access_token: @access_token }
      request = HTTPRequest.new path: "/#{@id}", params: params
      request.run.body["access_token"]
    end

    def default_options
      { period: "total_over_range" }
    end
  end
end
