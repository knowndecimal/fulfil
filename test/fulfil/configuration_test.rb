# frozen_string_literal: true

require 'test_helper'

module Fulfil
  class ConfigurationTest < MiniTest::Test
    def test_retry_on_rate_limit?
      refute Fulfil.config.retry_on_rate_limit?

      with_fulfil_config do |config|
        config.retry_on_rate_limit = true
        assert Fulfil.config.retry_on_rate_limit?
      end
    end
  end
end
