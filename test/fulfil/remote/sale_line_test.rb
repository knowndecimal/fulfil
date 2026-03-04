# frozen_string_literal: true

require 'test_helper'

module Fulfil
  module Remote
    class SaleLineTest < Minitest::Test
      def test_from_fulfil_maps_expected_attributes
        raw_sale_line = {
          'id' => 217_937,
          'sale' => [213_112, 'SO79797'],
          'product' => [53_101, 'Widget XL'],
          'quantity' => 1,
          'unit_price' => 60.0,
          'amount' => 60.0,
          'description' => 'Widget XL'
        }

        sale_line = SaleLine.from_fulfil(raw_sale_line)

        assert_equal 217_937, sale_line.id
        assert_equal [213_112, 'SO79797'], sale_line.sale
        assert_equal 213_112, sale_line.sale_id
        assert_equal 53_101, sale_line.product_id
        assert_in_delta 1.0, sale_line.quantity
        assert_in_delta 60.0, sale_line.unit_price
        assert_in_delta 60.0, sale_line.amount
        assert_equal 'Widget XL', sale_line.description
      end

      def test_sale_record_uses_sale_id
        sale_line = SaleLine.new(sale: [100, 'SO100'])

        Sale.stub(:find, :sale_record) do
          assert_equal :sale_record, sale_line.sale_record
        end
      end

      def test_sale_record_returns_nil_when_sale_missing
        sale_line = SaleLine.new(sale: nil)

        assert_nil sale_line.sale_record
      end
    end
  end
end
