# frozen_string_literal: true

require 'fulfil/converter'

module Fulfil
  # Parses domain payloads and converts Date/DateTime objects into Fulfil's expected format.
  class DomainParser
    attr_reader :domain

    def initialize(domain)
      @domain = domain
    end

    def parsed
      convert(domain)
    end

    private

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
