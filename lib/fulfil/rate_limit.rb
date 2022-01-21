# frozen_string_literal: true

module Fulfil
  # The `Fulfil::RateLimit` allows clients to keep track of their API usage.
  class RateLimit
    attr_reader :limit, :requests_left, :resets_at

    def initialize
      @limit = 0
      @requests_left = 0
      @resets_at = nil
    end

    # Analyses the rate limit based on the response headers from Fulfil.
    # @param headers [HTTP::Headers] The HTTP response headers from Fulfil.
    # @return [Fulfil::RateLimit]
    def analyse!(headers)
      self.limit = headers['X-RateLimit-Limit']
      self.requests_left = headers['X-RateLimit-Remaining']
      self.resets_at = headers['X-RateLimit-Reset']

      raise Fulfil::RateLimitExceeded unless requests_left?
    end

    # Returns whether there are any requests left in the current rate limit window.
    # @return [Boolean]
    def requests_left?
      requests_left.positive?
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
