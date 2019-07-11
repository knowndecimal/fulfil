require 'minitest/autorun'
require 'fulfil/query'

class Fulfil::QueryTest < Minitest::Test
  def setup
    @query = Fulfil::Query.new
  end

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
    @query.search(name: "chris%")
    assert_equal [['name', 'ilike', 'chris%']], @query.query
  end

  def test_case_sensitive_wildcard_query
    @query.search(name: "chris%", options: { case_sensitive: true })
    assert_equal [['name', 'like', 'chris%']], @query.query
  end

  def test_combined_query
    @query.search(id: 1)
    @query.search(sale: [1])

    assert_equal [['id', '=', 1], ['sale', 'in', [1]]], @query.query
  end

  def test_multiple_queries
    @query.search(id: 1, sale: [1])
    assert_equal [['id', '=', 1], ['sale', 'in', [1]]], @query.query
  end

  def test_nested_queries
    @query.search(sale: { id: [123] })
    assert_equal [['sale.id', 'in', [123]]], @query.query
  end
end
