# frozen_string_literal: true

require 'fulfil/converter'
require 'fulfil/concerns/html_entity_handler'

module Fulfil
  # Parses domain arrays and converts Date/DateTime objects into Fulfil's expected format
  # Handles the conversion of Ruby objects to Fulfil-compatible JSON structures
  class DomainParser
    include Concerns::HtmlEntityHandler

    attr_reader :domain

    def initialize(domain)
      @domain = domain
    end

    def parsed
      with_disabled_html_entities do
        domain.map { |values| update_values(values) }
      end
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
  end
end
