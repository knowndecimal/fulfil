# frozen_string_literal: true

module Fulfil
  module ResponseParser
    class UnhandledTypeError < StandardError
      attr_reader :value

      def initialize(msg, value)
        @value = value
        super(msg)
      end
    end

    # Handle value objects, for example:
    #
    # "order_date": {
    #   "__class__": "date",
    #   "iso_string": "2019-07-08"
    # }
    #
    def self.mapped_value_field(value:)
      return value unless value.is_a?(Hash) && value['__class__']

      json_class = value['__class__']

      case json_class
      when 'date'
        date = value['iso_string']
        Date.parse(date)
      when 'datetime'
        time = value['iso_string']
        DateTime.parse(time)
      when 'Decimal', 'timedelta'
        value['decimal'].to_f
      else
        raise UnhandledTypeError.new(
          "received a value that we don't know how to handle: #{json_class}",
          json_class
        )
      end
    end

    def self.group(key_value_tuples)
      key_value_tuples
        .group_by { |kv_tuple| kv_tuple[0][0] }
        .map do |group_key, kv_tuples|
        if kv_tuples.length == 1
          [group_key, mapped_value_field(value: kv_tuples[0][1])]
        else
          id = kv_tuples[0]
          attrs = kv_tuples[1..].map { |tuple| [tuple[0][1..], tuple[1]] }
          [group_key, [['id', id[1]]].concat(group(attrs)).to_h]
        end
      end
    end

    def self.parse(item:)
      key_value_tuples = item.to_a.map { |item_tuple| [item_tuple[0].split('.'), item_tuple[1]] }
      group(key_value_tuples).to_h
    end
  end
end
