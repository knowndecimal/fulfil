# frozen_string_literal: true

require 'test_helper'

module Fulfil
  class RateLimitTest < Minitest::Test
    def test_rate_limit_analyse
      rate_limit = Fulfil::RateLimit.new

      assert rate_limit.analyse!(
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

      refute_predicate rate_limit, :requests_left?

      rate_limit.requests_left = 10

      assert_predicate rate_limit, :requests_left?

      rate_limit.requests_left = 0

      refute_predicate rate_limit, :requests_left?
    end

    def test_rate_limit_notification_handler
      rate_limit = Fulfil::RateLimit.new

      notification_handler_mock = Minitest::Mock.new
      notification_handler_mock.expect(:call, 'to be called')

      with_fulfil_config do |config|
        config.rate_limit_notification_handler = notification_handler_mock

        begin
          rate_limit.analyse!(
            {
              'X-RateLimit-Limit' => '10',
              'X-RateLimit-Remaining' => '0',
              'X-RateLimit-Reset' => Time.now.utc.to_i
            }
          )
        rescue Fulfil::RateLimitExceeded
          # We want to ignore the `Fulfil::RateLimitExceeded` as we're testing the
          # notification handler in this test case.
          true
        end

        assert_mock notification_handler_mock
      end
    end

    def test_missing_rate_limit_notification_handler
      rate_limit = Fulfil::RateLimit.new

      notification_handler_mock = Minitest::Mock.new
      notification_handler_mock.expect(:call, 'to be called')

      with_fulfil_config do |config|
        config.rate_limit_notification_handler = nil

        begin
          rate_limit.analyse!(
            {
              'X-RateLimit-Limit' => '10',
              'X-RateLimit-Remaining' => '9',
              'X-RateLimit-Reset' => Time.now.utc.to_i
            }
          )
        rescue Fulfil::RateLimitExceeded
          # We want to ignore the `Fulfil::RateLimitExceeded` as we're testing the
          # notification handler in this test case.
          true
        end

        refute_mock notification_handler_mock
      end
    end
  end
end
