# frozen_string_literal: true

require 'minitest/autorun'

module Fulfil
  class RateLimitHeadersTest < Minitest::Test
    def test_default_values
      headers = Fulfil::RateLimitHeaders.new

      assert_equal Fulfil::RateLimitHeaders::DEFAULT_REQUEST_LIMIT, headers.limit
      assert_equal Fulfil::RateLimitHeaders::DEFAULT_REQUESTS_LEFT, headers.requests_left
      assert_nil Fulfil::RateLimitHeaders::DEFAULT_RESETS_AT
    end

    def test_rate_limit_assignments
      headers = Fulfil::RateLimitHeaders.new

      headers.limit = '10'

      assert_equal 10, headers.limit

      headers.requests_left = '9'

      assert_equal 9, headers.requests_left

      headers.resets_at = Time.now.utc.to_i

      assert_in_delta Time.now.to_datetime, headers.resets_at
    end
  end
end
