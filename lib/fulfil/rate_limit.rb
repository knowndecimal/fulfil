# frozen_string_literal: true

module Fulfil
  # The `Fulfil::RateLimit` allows clients to keep track of their API usage and
  # to analyze Fulfil's response HTTP headers.
  class RateLimit
    attr_accessor :limit, :requests_left, :resets_at

    # Analyses the rate limit based on the response headers from Fulfil.
    # @param headers [HTTP::Headers] The HTTP response headers from Fulfil.
    # @return [Fulfil::RateLimit]
    def analyse!(headers)
      rate_limit_headers = RateLimitHeaders.new(headers)

      self.limit = rate_limit_headers.limit
      self.requests_left = rate_limit_headers.requests_left
      self.resets_at = rate_limit_headers.resets_at

      raise Fulfil::RateLimitExceeded unless requests_left?
    end

    # Returns whether there are any requests left in the current rate limit window.
    # @return [Boolean]
    def requests_left?
      requests_left&.positive?
    end
  end
end
