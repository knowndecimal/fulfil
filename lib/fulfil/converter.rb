# frozen_string_literal: true

module Fulfil
  # Converts Ruby date-like objects into the object format expected by Fulfil.
  class Converter
    class << self
      # Convert a Date or DateTime into Fulfil's datetime object payload.
      #
      # @param date_or_datetime [Date, DateTime]
      # @return [Hash, nil]
      def date_or_datetime_as_object(date_or_datetime)
        case date_or_datetime
        when Date
          date_as_object(date_or_datetime)
        when DateTime
          datetime_as_object(date_or_datetime)
        end
      end

      # Convert a DateTime to Fulfil's UTC datetime payload format.
      #
      # @param datetime [DateTime]
      # @return [Hash]
      def datetime_as_object(datetime)
        {
          __class__: 'datetime',
          iso_string: datetime.new_offset(0).iso8601
        }
      end

      # Convert a Date to Fulfil's datetime payload format.
      #
      # @param date [Date]
      # @return [Hash]
      def date_as_object(date)
        datetime_as_object(date.to_datetime)
      end
    end
  end
end
