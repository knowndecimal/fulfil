# frozen_string_literal: true

require 'fulfil/converter'

module Fulfil
  # Walks a Fulfil domain payload and converts Date/DateTime values recursively.
  class DomainParser
    attr_reader :domain

    # @param domain [Array] Fulfil domain payload (including nested logical groups)
    def initialize(domain)
      @domain = domain
    end

    # Returns a converted copy of the domain payload.
    #
    # @return [Array]
    def parsed
      convert(domain)
    end

    private

    # Recursively convert nested domain structures while preserving all other values.
    #
    # @param value [Object]
    # @return [Object]
    def convert(value)
      case value
      when DateTime
        Converter.datetime_as_object(value)
      when Date
        Converter.date_as_object(value)
      when Array
        value.map { |item| convert(item) }
      when Hash
        value.transform_values { |item| convert(item) }
      else
        value
      end
    end
  end
end
