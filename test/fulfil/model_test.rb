require 'minitest/autorun'
require 'minitest/mock'
require 'fulfil/model'

module Fulfil
  class ModelTest < Minitest::Test
    def test_query
      stub = Minitest::Mock.new
      stub.expect(:search, [], [Hash])

      sales = Fulfil::Model.new(client: stub, model_name: 'sale.sale')
      sales.query(id: [1, 2, 3])

      assert_equal [['id', 'in', [1, 2, 3]]], sales.query
      assert_equal [], sales.all
    end
  end
end
