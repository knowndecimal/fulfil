# frozen_string_literal: true

module Fulfil
  # The `Fulfil::RateLimitHeaders` parses Fulfil HTTP rate limit headers and
  # formats them to a more usable format.
  class RateLimitHeaders
    # Test suites might mock (or at least should mock) the requests to Fulfil.
    # However, most of these test suites will not mock the response headers.
    # To make sure those test suites don't break, we're setting some defaults for them.
    DEFAULT_REQUEST_LIMIT = 10
    DEFAULT_REQUESTS_LEFT = 9
    DEFAULT_RESETS_AT = nil

    attr_reader :limit, :requests_left, :resets_at

    def initialize(headers = {})
      self.limit = headers['X-RateLimit-Limit'] || DEFAULT_REQUEST_LIMIT
      self.requests_left = headers['X-RateLimit-Remaining'] || DEFAULT_REQUESTS_LEFT
      self.resets_at = headers['X-RateLimit-Reset'] || DEFAULT_RESETS_AT
    end

    # Sets the maximum number of requests you're permitted to make per second.
    # @param value [String] The maximum number of requests per second.
    # @return [Integer] The maximum number of requests per second.
    def limit=(value)
      @limit = value.to_i
    end

    # Sets number of requests remaining in the current rate limit window.
    # @param value [String] The remaining number of requests for the current time window.
    # @return [Integer] The remaining number of requests for the current time window.
    def requests_left=(value)
      @requests_left = value.to_i
    end

    # Sets the time at which the current rate limit window resets in UTC epoch seconds.
    # @param value [Integer|nil] Time as an integer in UTC epoch seconds.
    # @return [DataTime|nil] The moment the rate limit resets.
    def resets_at=(value)
      @resets_at =
        if value.nil?
          nil
        else
          Time.at(value.to_i).utc.to_datetime
        end
    end
  end
end
