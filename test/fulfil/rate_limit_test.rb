# frozen_string_literal: true

require 'minitest/autorun'

class RateLimitTest < Minitest::Test
  def test_default_values
    rate_limit = Fulfil::RateLimit.new

    assert_equal 0, rate_limit.limit
    assert_equal 0, rate_limit.requests_left
    assert_nil rate_limit.resets_at
  end

  def test_rate_limit_assignments
    rate_limit = Fulfil::RateLimit.new

    rate_limit.limit = '10'
    assert_equal 10, rate_limit.limit

    rate_limit.requests_left = '9'
    assert_equal 9, rate_limit.requests_left

    rate_limit.resets_at = Time.now.utc.to_i
    assert_in_delta Time.now.to_datetime, rate_limit.resets_at
  end

  def test_rate_limit_analyse
    rate_limit = Fulfil::RateLimit.new

    rate_limit.analyse!(
      {
        'X-RateLimit-Limit' => '10',
        'X-RateLimit-Remaining' => '9',
        'X-RateLimit-Reset' => Time.now.utc.to_i
      }
    )

    assert_raises Fulfil::RateLimitExceeded do
      rate_limit.analyse!(
        {
          'X-RateLimit-Limit' => '10',
          'X-RateLimit-Remaining' => '0',
          'X-RateLimit-Reset' => Time.now.utc.to_i
        }
      )
    end
  end

  def test_rate_limit_requests_left
    rate_limit = Fulfil::RateLimit.new
    refute rate_limit.requests_left?

    rate_limit.requests_left = 10
    assert rate_limit.requests_left?

    rate_limit.requests_left = 0
    refute rate_limit.requests_left?
  end
end
