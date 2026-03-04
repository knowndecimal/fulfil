# frozen_string_literal: true

require 'test_helper'

module Fulfil
  module Remote
    class ProductTest < Minitest::Test
      def test_from_fulfil_maps_expected_attributes
        raw_product = {
          'id' => 123,
          'variant_name' => 'Widget XL',
          'list_price' => 19.95,
          'quantity_available' => 7.5,
          'code' => 'WXL-001',
          'template' => ['Widget'],
          'default_uom' => ['Each']
        }

        product = Product.from_fulfil(raw_product)

        assert_equal 123, product.id
        assert_equal 'Widget XL', product.name
        assert_in_delta 19.95, product.price
        assert_in_delta 7.5, product.quantity_available
        assert_equal 'WXL-001', product.sku
        assert_equal ['Widget'], product.template
        assert_equal ['Each'], product.unit
      end

      def test_fulfil_model_name
        assert_equal 'product.product', Product::FULFIL_MODEL_NAME
      end

      def test_attributes_constant
        expected = %w[id code default_uom list_price quantity_available variant_name template]

        assert_equal expected, Product::ATTRIBUTES
      end
    end
  end
end
