# frozen_string_literal: true

require 'fulfil/converter'

module Fulfil
  # The Fulfil::DomainParser module provides utility methods for converting
  # Date and DateTime objects into a standardized hash format.
  # The module iterates over given parameters, identifies
  # Date and DateTime objects, and converts them into a hash with a class descriptor
  # and an ISO 8601 formatted string.
  class DomainParser
    attr_reader :domain

    def initialize(domain)
      @domain = domain

      disable_escape_html_entities
    end

    def parsed
      new_domain = domain.map do |values|
        update_values(values)
      end

      enable_escape_html_entities
      new_domain
    end

    def update_values(values)
      values.map do |value|
        case value.class.name
        when 'Date'
          date_as_object(value)
        when 'DateTime'
          datetime_as_object(value)
        else
          value
        end
      end
    end

    private

    def date_as_object(date)
      Converter.date_as_object(date)
    end

    def datetime_as_object(datetime)
      Converter.datetime_as_object(datetime)
    end

    def disable_escape_html_entities
      return unless defined?(ActiveSupport) && ActiveSupport.respond_to?(:escape_html_entities_in_json=)

      ActiveSupport.escape_html_entities_in_json = false
    end

    def enable_escape_html_entities
      return unless defined?(ActiveSupport) && ActiveSupport.respond_to?(:escape_html_entities_in_json=)

      ActiveSupport.escape_html_entities_in_json = true
    end
  end
end
