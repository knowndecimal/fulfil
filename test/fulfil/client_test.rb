require 'test_helper'

module Fulfil
  class ClientTest < MiniTest::Test
    def test_invalid_client
      assert_raises('InvalidClientError') { Fulfil::Client.new(subdomain: nil, token: nil) }
    end

    def test_find_one
      stub_fulfil_get('sale.sale/213112', 'sale_sale')

      client = Fulfil::Client.new
      response = client.find_one(model: 'sale.sale', id: 213_112)

      assert_equal 213_112, response['id']
    end

    def test_find_many
      stub_fulfil_put('sale.sale/read', 'sale_sale_read', '[[213112,213114],null]')

      client = Fulfil::Client.new
      orders = client.find_many(model: 'sale.sale', ids: [213_112, 213_114])

      assert_equal 2, orders.count
      assert_equal 213_112, orders.first['id']
      assert_equal 213_114, orders.last['id']
    end

    def test_count
      stub_fulfil_put('sale.sale/search_count', 'sale_sale_count', '[[]]')

      client = Fulfil::Client.new
      order_count = client.count(model: 'sale.sale', domain: [])

      assert_equal 362_560, order_count
    end
  end
end
