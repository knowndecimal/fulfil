# frozen_string_literal: true

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

    def test_retry_on_request_failure_when_configured
      sale_id = 404

      stub_request(:get, fulfil_url_for("sale.sale/#{sale_id}"))
        .to_return(
          { status: 200, body: '', headers: { 'Content-Type': 'application/json', 'X-RateLimit-Remaining': 0 } },
          { status: 200, body: { id: 100 }.to_json, headers: { 'Content-Type': 'application/json' } }
        )

      with_fulfil_config do |config|
        config.retry_on_rate_limit = true
        config.retry_on_rate_limit_wait = 0.05 # Wait for a very short period to keep the tests fast.

        assert_equal({ 'id' => 100 }, Fulfil::Client.new.find_one(model: 'sale.sale', id: sale_id))
      end
    end

    def test_do_not_retry_when_retry_is_disabled
      sale_id = 404

      stub_request(:get, fulfil_url_for("sale.sale/#{sale_id}"))
        .to_return(status: 200, body: '', headers: { 'Content-Type': 'application/json', 'X-RateLimit-Remaining': 0 })

      with_fulfil_config do |config|
        config.retry_on_rate_limit = false

        assert_raises Fulfil::RateLimitExceeded do
          Fulfil::Client.new.find_one(model: 'sale.sale', id: sale_id)
        end
      end
    end
  end
end
