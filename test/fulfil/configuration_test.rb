# frozen_string_literal: true

require 'test_helper'

module Fulfil
  class ConfigurationTest < Minitest::Test
    def test_retry_on_rate_limit?
      refute_predicate Fulfil.config, :retry_on_rate_limit?

      with_fulfil_config do |config|
        config.retry_on_rate_limit = true

        assert_predicate Fulfil.config, :retry_on_rate_limit?
      end
    end

    def test_rate_limit_retry_defaults
      assert_equal 3, Fulfil.config.retry_on_rate_limit_max_attempts
      assert_in_delta(0.2, Fulfil.config.retry_on_rate_limit_jitter)
      assert Fulfil.config.retry_on_rate_limit_use_reset_at
    end

    def test_default_logger
      assert_instance_of Logger, Fulfil.config.logger
    end

    def test_configured_logger
      with_fulfil_config do |config|
        config.logger = Logger.new('test.log')
      end

      assert_instance_of Logger, Fulfil.config.logger
    end
  end
end
