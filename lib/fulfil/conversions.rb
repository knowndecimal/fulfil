# frozen_string_literal: true

module Fulfil
  # The Fulfil::Conversions module provides utility methods for converting
  # Date and DateTime objects into a standardized hash format.
  # The module iterates over given parameters, identifies
  # Date and DateTime objects, and converts them into a hash with a class descriptor
  # and an ISO 8601 formatted string.
  class Conversions
    class << self
      def update_date_and_datetime_fields(domain)
        domain.each do |params|
          update_date_and_datetime_fields_in_params(params)
        end
      end

      private

      def update_date_and_datetime_fields_in_params(params)
        params.map! do |param|
          case param
          when Date
            date_as_object(param)
          when DateTime
            datetime_as_object(param)
          else
            param
          end
        end
      end

      def datetime_as_object(datetime)
        {
          __class__: 'datetime',
          iso_string: datetime.new_offset(0).iso8601
        }
      end

      def date_as_object(date)
        datetime_as_object(date.to_datetime)
      end
    end
  end
end
