# frozen_string_literal: true

module Fulfil
  # The `Fulfil::Configuration` contains the available configuration options
  # for the `Fulfil` gem.
  class Configuration
    # Allow the `Fulfil::Client` to automatically retry when the rate limit is hit.
    # By default, the `Fulfil::Client` will wait 1 second before retrying again.
    attr_accessor :retry_on_rate_limit
    attr_accessor :retry_on_rate_limit_wait

    def initialize
      @retry_on_rate_limit = false
      @retry_on_rate_limit_wait = 1
    end

    def retry_on_rate_limit?
      @retry_on_rate_limit
    end
  end

  # Returns Fulfil's configuration.
  # @return [Fulfil::Configuration] Fulfil's configuration
  def self.config
    @config ||= Configuration.new
  end

  # Allows setting a new configuration for Fulfil.
  # @return [Fulfil::Configuration] Fulfil's new configuration
  def self.config=(configuration)
    @config = configuration
  end

  # Allows modifying Fulfil's configuration.
  #
  # Example usage:
  #
  #   Fulfil.configure do |config|
  #     config.api_key = "..."
  #   end
  #
  def self.configure
    yield(config)
  end
end
