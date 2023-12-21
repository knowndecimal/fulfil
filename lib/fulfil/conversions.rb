module Fulfil
  class Conversions
    class << self
      def update_date_and_datetime_fields(domain)
        domain.each do |params|
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
