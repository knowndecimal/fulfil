# frozen_string_literal: true

require 'fulfil/version'
require 'fulfil/error'
require 'fulfil/configuration'
require 'fulfil/client'
require 'fulfil/model'
require 'fulfil/remote/resource'
require 'fulfil/remote/product'
require 'fulfil/remote/sale'
require 'fulfil/remote/sale_line'
require 'fulfil/interactive_report'
require 'fulfil/response_handler'
require 'fulfil/response_parser'

# Rate limiting
require 'fulfil/rate_limit'
require 'fulfil/rate_limit_headers'
require 'fulfil/rate_limit_retry_wait'

module Fulfil
  RemoteResource = Remote::Resource
  RemoteProduct = Remote::Product
  RemoteSale = Remote::Sale
  RemoteSaleLine = Remote::SaleLine

  def self.rate_limit
    @rate_limit ||= RateLimit.new
  end
end
