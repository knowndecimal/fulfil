# frozen_string_literal: true

require 'minitest/autorun'
require 'date'
require 'fulfil/domain_parser'
require 'fulfil/converter'

module Fulfil
  class DomainParserTest < Minitest::Test
    def test_parses_simple_date_values
      date = Date.new(2024, 1, 1)

      parsed = DomainParser.new([['create_date', '>=', date]]).parsed

      assert_equal [['create_date', '>=', Converter.date_as_object(date)]], parsed
    end

    def test_parses_nested_domains_recursively
      datetime = DateTime.new(2024, 1, 1, 12, 0, 0)
      date = Date.new(2024, 2, 1)
      domain = [
        'OR',
        ['create_date', '>=', datetime],
        ['AND', ['ship_date', '<=', date], ['state', '=', 'done']]
      ]

      parsed = DomainParser.new(domain).parsed

      assert_equal(
        [
          'OR',
          ['create_date', '>=', Converter.datetime_as_object(datetime)],
          ['AND', ['ship_date', '<=', Converter.date_as_object(date)], ['state', '=', 'done']]
        ],
        parsed
      )
    end
  end
end
