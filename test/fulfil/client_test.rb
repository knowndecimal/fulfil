# frozen_string_literal: true

require 'test_helper'
require 'date'

module Fulfil
  class ClientTest < Minitest::Test
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

    def test_date_conversion_in_search
      date = Date.new(2022, 1, 1)
      datetime = date.to_datetime
      utc_datetime = datetime.new_offset(0)
      expected_formatted_date = {
        __class__: 'datetime',
        iso_string: utc_datetime.iso8601
      }

      # Convert the expected hash's symbol keys to strings for comparison
      expected_formatted_date_with_string_keys = expected_formatted_date.transform_keys(&:to_s)

      stub_request(:put, fulfil_url_for('sale.sale/search_read'))
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      client = Fulfil::Client.new
      fulfil_model = Fulfil::Model.new(client: client, model_name: 'sale.sale')
      fulfil_model.search(domain: [['create_date', '>=', date]])

      assert_requested(:put, fulfil_url_for('sale.sale/search_read'), times: 1) do |request|
        actual_formatted_date = JSON.parse(request.body).dig(0, 0, 2)

        assert_equal expected_formatted_date_with_string_keys, actual_formatted_date
      end
    end

    def test_datetime_conversion_in_search
      datetime = DateTime.new(2022, 1, 1, 12, 0, 0)
      utc_datetime = datetime.new_offset(0)
      expected_formatted_date = {
        __class__: 'datetime',
        iso_string: utc_datetime.iso8601
      }

      # Convert the expected hash's symbol keys to strings for comparison
      expected_formatted_date_with_string_keys = expected_formatted_date.transform_keys(&:to_s)

      stub_request(:put, fulfil_url_for('sale.sale/search_read'))
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      client = Fulfil::Client.new
      fulfil_model = Fulfil::Model.new(client: client, model_name: 'sale.sale')
      fulfil_model.search(domain: [['create_date', '>=', datetime]])

      assert_requested(:put, fulfil_url_for('sale.sale/search_read'), times: 1) do |request|
        actual_formatted_date = JSON.parse(request.body).dig(0, 0, 2)

        assert_equal expected_formatted_date_with_string_keys, actual_formatted_date
      end
    end

    def test_datetime_conversion_in_count
      datetime = DateTime.new(2022, 1, 1, 12, 0, 0)
      utc_datetime = datetime.new_offset(0)
      expected_formatted_date = {
        __class__: 'datetime',
        iso_string: utc_datetime.iso8601
      }

      # Convert the expected hash's symbol keys to strings for comparison
      expected_formatted_date_with_string_keys = expected_formatted_date.transform_keys(&:to_s)

      stub_request(:put, fulfil_url_for('sale.sale/search_count'))
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      client = Fulfil::Client.new
      fulfil_model = Fulfil::Model.new(client: client, model_name: 'sale.sale')
      fulfil_model.count(domain: [['create_date', '>=', datetime]])

      assert_requested(:put, fulfil_url_for('sale.sale/search_count'), times: 1) do |request|
        actual_formatted_date = JSON.parse(request.body).dig(0, 0, 2)

        assert_equal expected_formatted_date_with_string_keys, actual_formatted_date
      end
    end
  end
end
