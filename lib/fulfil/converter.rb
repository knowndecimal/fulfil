# frozen_string_literal: true

module Fulfil
  # The Fulfil::Conversions module provides utility methods for converting
  # Date and DateTime objects into a standardized hash format.
  class Converter
    class << self
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
