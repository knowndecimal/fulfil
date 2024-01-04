# frozen_string_literal: true

module Fulfil
  # The Fulfil::Conversions module provides utility methods for converting
  # Date and DateTime objects into a standardized hash format.
  class Converter
    class << self
      def date_or_datetime_as_object(date_or_datetime)
        case date_or_datetime
        when Date
          date_as_object(date_or_datetime)
        when DateTime
          datetime_as_object(date_or_datetime)
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
