# frozen_string_literal: true

module Fulfil
  class Query
    def initialize
      @matchers = []
    end

    def query
      @matchers
    end

    def search(*args)
      options = args.first { |arg| arg.is_a?(Hash) && arg.key?(:options) }.fetch(:options, {})

      args.each do |arg|
        arg.each do |field, value|
          next if value == options

          @matchers.concat(build_search_term(field: field, value: value, options: options))
        end
      end

      self
    end

    def exclude(*args)
      options = args.first { |arg| arg.is_a?(Hash) && arg.key?(:options) }.fetch(:options, {})

      terms = args.flat_map do |arg|
        arg.map do |field, value|
          next if value == options

          build_exclude_term(field: field, value: value, options: options)
        end
      end

      if terms.length > 1
        @matchers.push(['OR'].concat(terms))
      else
        @matchers.concat(terms.first)
      end

      self
    end

    private

    # Fulfil Query Syntax:
    #
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
    def build_search_term(field:, value:, options:, prefix: nil)
      key = [prefix, field.to_s].compact.join('.')

      case value.class.name
      when 'Array'
        [[key, 'in', value]]
      when 'Fixnum', 'Integer'
        [[key, '=', value]]
      when 'Range'
        [
          [key, '>=', value.first],
          [key, '<=', value.last]
        ]
      when 'String'
        if options[:case_sensitive]
          [[key, 'like', value]]
        else
          [[key, 'ilike', value]]
        end
      when 'Hash'
        value.flat_map do |nested_field, nested_value|
          build_search_term(prefix: field, field: nested_field, value: nested_value, options: options)
        end
      else
        raise "Unhandled value type: #{value} (#{value.class.name})"
      end
    end

    def build_exclude_term(field:, value:, options:, prefix: nil)
      key = [prefix, field.to_s].compact.join('.')

      case value.class.name
      when 'Array'
        [[key, 'not in', value]]
      when 'Fixnum', 'Integer'
        [[key, '!=', value]]
      when 'Range'
        [
          [key, '<', value.first],
          [key, '>', value.last]
        ]
      when 'Hash'
        value.flat_map do |nested_field, nested_value|
          build_exclude_term(prefix: field, field: nested_field, value: nested_value, options: options)
        end
      else
        raise "Unhandled value type: #{value} (#{value.class.name})"
      end
    end
  end
end
