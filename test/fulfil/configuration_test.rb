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
