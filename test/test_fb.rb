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
end
