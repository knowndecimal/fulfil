# frozen_string_literal: true

require 'minitest/autorun'

class RateLimitTest < Minitest::Test
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
