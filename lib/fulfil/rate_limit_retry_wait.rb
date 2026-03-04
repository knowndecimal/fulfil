# frozen_string_literal: true

module Fulfil
  # Calculates retry wait duration using reset-aware timing and jitter fallback.
  class RateLimitRetryWait
    def self.call(config:, reset_at:, now: Time.now.utc)
      wait = reset_aware_wait(config: config, reset_at: reset_at, now: now) || config.retry_on_rate_limit_wait.to_f
      apply_jitter(wait, config.retry_on_rate_limit_jitter)
    end

    def self.reset_aware_wait(config:, reset_at:, now:)
      return unless config.retry_on_rate_limit_use_reset_at
      return unless reset_at

      reset_time = reset_at.respond_to?(:to_time) ? reset_at.to_time : Time.at(reset_at.to_i).utc
      [reset_time - now, 0].max
    end

    def self.apply_jitter(wait, jitter_ratio)
      jitter_ratio = jitter_ratio.to_f
      return wait if jitter_ratio <= 0

      min = wait * (1 - jitter_ratio)
      max = wait * (1 + jitter_ratio)
      rand(min..max)
    end
  end
end
