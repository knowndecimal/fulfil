# frozen_string_literal: true

require 'minitest/autorun'

class RateLimitTest < Minitest::Test
  def setup
    @current_time = Time.now

    @response_headers = {
      'X-RateLimit-Limit' => '10',
      'X-RateLimit-Remaining' => '9',
      'X-RateLimit-Reset' => @current_time.utc.to_i
    }
  end

  def test_default_values
    rate_limit = Fulfil::RateLimit.new

    assert_equal 0, rate_limit.limit
    assert_equal 0, rate_limit.requests_left
    assert_nil rate_limit.resets_at
  end

  def test_rate_limit_assignments
    rate_limit = Fulfil::RateLimit.new
    rate_limit.analyse!(@response_headers)

    assert_equal 10, rate_limit.limit
    assert_equal 9, rate_limit.requests_left
    assert_in_delta @current_time.to_datetime, rate_limit.resets_at
  end

  def test_rate_limit_requests_left
    rate_limit = Fulfil::RateLimit.new
    refute rate_limit.requests_left?

    rate_limit.analyse!(@response_headers)
    assert rate_limit.requests_left?
  end
end
