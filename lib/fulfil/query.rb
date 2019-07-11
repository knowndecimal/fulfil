module Fulfil
  class Query
    def initialize
      @matchers = []
    end

    # Exact Match: (Integer)
    #   * =
    #
    # Case Insensitive Match: (String)
    #   * 'ilike'
    #
    # Case Sensitive Match: (String)
    #   * 'like'
    #
    # Comparison Operators: (Numeric/Currency, Integer, Float, Date, Datetime)
    #   * >
    #   * >=
    #   * <
    #   * <=
    #   * !=
    #
    # IN, NOT IN: (Array)
    #
    def build_search_term(prefix: nil, field:, value:, options:)
      key = [prefix, field.to_s].compact.join('.')

      case value.class.name
      when 'Array'
        [[key, 'in', value]]
      when 'Integer'
        [[key, '=', value]]
      when 'Range'
        [[key, '>=', value.first], [key, '<=', value.last]]
      when 'String'
        if options[:case_sensitive]
          [[key, 'like', value]]
        else
          [[key, 'ilike', value]]
        end
      when 'Hash'
        value.flat_map do |nested_field, nested_value|
          build_search_term(
            prefix: field,
            field: nested_field,
            value: nested_value,
            options: options
          )
        end
      end
    end

    def search(*args)
      options =
        args.first do |arg|
          arg.is_a?(Hash) && arg.keys.include?(:options)
        end.fetch(:options, {})

      args.each do |arg|
        arg.each do |field, value|
          next if value == options
          @matchers.concat(
            build_search_term(field: field, value: value, options: options)
          )
        end
      end
    end

    def query
      @matchers
    end
  end
end
