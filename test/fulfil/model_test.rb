# frozen_string_literal: true

require 'test_helper'

module Fulfil
  class ModelTest < Minitest::Test
    def test_query
      stub_request(:put, fulfil_url_for('sale.sale/search_read'))
        .and_return(status: 200, body: [].to_json, headers: { 'Content-Type': 'application/json'})

      sales = Fulfil::Model.new(client: Fulfil::Client.new, model_name: 'sale.sale')
      sales.query(id: [1, 2, 3])

      assert_equal [['id', 'in', [1, 2, 3]]], sales.query
      assert_equal [], sales.all
    end
  end
end
