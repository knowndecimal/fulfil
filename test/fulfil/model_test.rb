# frozen_string_literal: true

require 'test_helper'

module Fulfil
  class ModelTest < Minitest::Test
    def test_query
      stub_request(:put, fulfil_url_for('sale.sale/search_read'))
        .and_return(status: 200, body: [].to_json, headers: { 'Content-Type': 'application/json' })

      sales = Fulfil::Model.new(client: Fulfil::Client.new, model_name: 'sale.sale')
      sales.query(id: [1, 2, 3])

      assert_equal [['id', 'in', [1, 2, 3]]], sales.query
      assert_empty sales.all
    end

    def test_search_forwards_only_whitelisted_options
      context = { locations: [10] }
      base_url = fulfil_url_for('sale.sale/search_read')

      stub_request(:put, /#{Regexp.escape(base_url)}(\?.*)?/)
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type': 'application/json' })

      sales = Fulfil::Model.new(client: Fulfil::Client.new, model_name: 'sale.sale')
      sales.search(
        domain: [],
        fields: %w[id],
        limit: 25,
        offset: 10,
        sort: 'id DESC',
        context: { locations: [10] }
      )

      assert_requested(:put, /#{Regexp.escape(base_url)}(\?.*)?/, times: 1) do |request|
        query = URI.decode_www_form(URI(request.uri).query || '').to_h

        assert_equal context.to_json, query['context']
        assert_equal [[], 10, 25, 'id DESC', ['id']], JSON.parse(request.body)
      end
    end

    def test_search_rejects_unknown_keywords
      sales = Fulfil::Model.new(client: Fulfil::Client.new, model_name: 'sale.sale')

      assert_raises(ArgumentError) do
        sales.search(domain: [], foo: 'bar')
      end
    end
  end
end
