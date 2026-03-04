# frozen_string_literal: true

module Fulfil
  module Remote
    # Fulfil-backed representation of a product resource.
    #
    # @see Fulfil::Remote::Resource
    class Product < Resource
      # Fields requested from Fulfil for product reads.
      ATTRIBUTES = %w[
        id code default_uom list_price quantity_available variant_name template
      ].freeze

      # Fulfil model name.
      FULFIL_MODEL_NAME = 'product.product'

      # Builds a product instance from a raw Fulfil response row.
      #
      # @param raw_product [Hash] serialized product row from Fulfil
      # @return [Fulfil::Remote::Product]
      def self.from_fulfil(raw_product)
        new(
          id: raw_product['id'],
          name: raw_product['variant_name'],
          price: raw_product['list_price'],
          quantity_available: raw_product['quantity_available'],
          sku: raw_product['code'],
          template: raw_product['template'],
          unit: raw_product['default_uom']
        )
      end

      # @return [String, nil] variant name
      def name
        attributes['name']
      end

      # @return [Numeric, nil] list price
      def price
        attributes['price']
      end

      # @return [Numeric, nil] available quantity from Fulfil
      def quantity_available
        attributes['quantity_available']
      end

      # @return [String, nil] product code/sku
      def sku
        attributes['sku']
      end

      # @return [Object, nil] product template payload from Fulfil
      def template
        attributes['template']
      end

      # @return [Object, nil] default unit of measure payload
      def unit
        attributes['unit']
      end
    end
  end
end
