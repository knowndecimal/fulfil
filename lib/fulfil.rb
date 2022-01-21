# frozen_string_literal: true

require 'fulfil/version'
require 'fulfil/error'
require 'fulfil/client'
require 'fulfil/model'
require 'fulfil/interactive_report'
require 'fulfil/response_handler'
require 'fulfil/response_parser'
require 'fulfil/rate_limit'

module Fulfil
  def self.rate_limit
    @rate_limit ||= RateLimit.new
  end
end
