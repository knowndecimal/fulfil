# frozen_string_literal: true

require 'minitest/autorun'
require 'fulfil/query'

module Fulfil
  class QueryTest < Minitest::Test
    def setup
      @query = Fulfil::Query.new
    end

    # -- #query -----------------------

    def test_equals_query
      @query.search(id: 1)

      assert_equal [['id', '=', 1]], @query.query
    end

    def test_in_query
      @query.search(id: [1])

      assert_equal [['id', 'in', [1]]], @query.query
    end

    def test_range_query
      @query.search(id: 1..10)

      assert_equal [['id', '>=', 1], ['id', '<=', 10]], @query.query
    end

    def test_case_insensitive_wildcard_query
      @query.search(name: 'chris%')

      assert_equal [['name', 'ilike', 'chris%']], @query.query
    end

    def test_case_sensitive_wildcard_query
      @query.search(name: 'chris%', options: { case_sensitive: true })

      assert_equal [['name', 'like', 'chris%']], @query.query
    end

    def test_nested_queries
      @query.search(sale: { id: [123] })

      assert_equal [['sale.id', 'in', [123]]], @query.query
    end

    # -- #exclude -----------------------

    def test_equals_exclude
      @query.exclude(id: 1)

      assert_equal [['id', '!=', 1]], @query.query
    end

    def test_in_exclude
      @query.exclude(id: [1])

      assert_equal [['id', 'not in', [1]]], @query.query
    end

    def test_range_exclude
      @query.exclude(id: 1..10)

      assert_equal [['id', '<', 1], ['id', '>', 10]], @query.query
    end

    def test_case_insensitive_wildcard_exclude
      assert_raises { @query.exclude(name: 'chris%') }
    end

    def test_case_sensitive_wildcard_query_exclude
      assert_raises do
        @query.exclude(name: 'chris%', options: { case_sensitive: true })
      end
    end

    def test_nested_exclude
      @query.exclude(sale: { id: [123] })

      assert_equal [['sale.id', 'not in', [123]]], @query.query
    end

    # -- Combinations -------------------

    def test_combined_query
      @query.search(id: 1)
      @query.search(sale: [1])

      assert_equal [['id', '=', 1], ['sale', 'in', [1]]], @query.query
    end

    def test_multiple_queries
      @query.search(id: 1, sale: [1])

      assert_equal [['id', '=', 1], ['sale', 'in', [1]]], @query.query
    end

    def test_combined_exclusion
      @query.exclude(id: 1)
      @query.exclude(sale: [1])

      assert_equal [['id', '!=', 1], ['sale', 'not in', [1]]], @query.query
    end

    def test_multiple_exclusion
      @query.exclude(id: 1, sale: [1])

      # This has to be extra-nested because we don't know if there will be addition
      # queries coming after that should be "AND"-ed together with this
      assert_equal(
        [
          [
            'OR',
            [
              ['id', '!=', 1]
            ],
            [
              ['sale', 'not in', [1]]
            ]
          ]
        ],
        @query.query
      )
    end

    def test_single_exclude_then_query
      @query.exclude(id: 1)
            .search(sale: [2, 4, 6])

      assert_equal(
        [
          ['id', '!=', 1],
          ['sale', 'in', [2, 4, 6]]
        ],
        @query.query
      )
    end

    def test_many_exclude_then_query
      @query.exclude(id: 1, sale: [1])
            .search(sale: [2, 4, 6])

      assert_equal(
        [
          [
            'OR',
            [
              ['id', '!=', 1]
            ],
            [
              ['sale', 'not in', [1]]
            ]
          ],
          ['sale', 'in', [2, 4, 6]]
        ],
        @query.query
      )
    end

    def test_chaining
      @query.search(id: 1, sale: [1, 3, 5])
            .exclude(id: 2, sale: [2, 4, 6])

      assert_equal(
        [
          ['id', '=', 1],
          ['sale', 'in', [1, 3, 5]],
          [
            'OR',
            [
              ['id', '!=', 2]
            ],
            [
              ['sale', 'not in', [2, 4, 6]]
            ]
          ]
        ],
        @query.query
      )
    end
  end
end
