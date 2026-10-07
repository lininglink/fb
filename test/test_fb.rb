# frozen_string_literal: true

require "test_helper"

class TestFb < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Fb::VERSION
  end

  def test_client_secret_raises_configuration_error_when_missing
    config = Fb::Configuration.new
    config.client_secret = nil

    error = assert_raises(Fb::ConfigurationError) { config.client_secret }
    assert_includes error.message, "FB_CLIENT_SECRET"
  end

  def test_client_id_raises_configuration_error_when_missing
    config = Fb::Configuration.new
    config.client_id = nil

    error = assert_raises(Fb::ConfigurationError) { config.client_id }
    assert_includes error.message, "FB_CLIENT_ID"
  end

  def test_configuration_error_is_an_fb_error
    assert Fb::ConfigurationError < Fb::Error
  end

  def test_returns_configured_value_when_present
    config = Fb::Configuration.new
    config.client_secret = "secret"
    config.client_id = "id"

    assert_equal "secret", config.client_secret
    assert_equal "id", config.client_id
  end

  def test_video_exposes_attributes
    video = Fb::Video.new(id: "1", title: "Clip", length: 12.5, post_id: "2_1", access_token: "token")

    assert_equal "1", video.id
    assert_equal "Clip", video.title
    assert_equal 12.5, video.length
    assert_equal "2_1", video.post_id
  end

  def test_page_access_token_presence
    assert Fb::Page.new(id: "1", access_token: "token").access_token?
    refute Fb::Page.new(id: "1").access_token?
  end

  def test_page_exposes_owning_business
    page = Fb::Page.new(id: "1", business: { id: "2", name: "Biz" })

    assert_equal "2", page.business[:id]
    assert_nil Fb::Page.new(id: "1").business
  end
end
