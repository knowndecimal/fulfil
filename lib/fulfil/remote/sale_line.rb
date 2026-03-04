# frozen_string_literal: true

module Fulfil
  module Remote
    # Fulfil-backed representation of a sale line resource.
    #
    # @see Fulfil::Remote::Resource
    class SaleLine < Resource
      # Fields requested from Fulfil for sale line reads.
      ATTRIBUTES = %w[
        id sale product quantity unit_price amount description
      ].freeze

      # Fulfil model name.
      FULFIL_MODEL_NAME = 'sale.line'

      # Builds a sale line instance from a raw Fulfil response row.
      #
      # @param raw_sale_line [Hash] serialized sale line row from Fulfil
      # @return [Fulfil::Remote::SaleLine]
      def self.from_fulfil(raw_sale_line)
        new(
          id: raw_sale_line['id'],
          sale_ref: raw_sale_line['sale'],
          product_ref: raw_sale_line['product'],
          quantity: raw_sale_line['quantity'],
          unit_price: raw_sale_line['unit_price'],
          amount: raw_sale_line['amount'],
          description: raw_sale_line['description']
        )
      end

      # @return [Integer, Array, nil] sale reference payload
      def sale_ref
        attributes['sale_ref']
      end

      # @return [Integer, nil] sale id extracted from payload
      def sale_id
        extract_remote_id(sale_ref)
      end

      # @return [Integer, Array, nil] product reference payload
      def product_ref
        attributes['product_ref']
      end

      # @return [Integer, nil] product id extracted from payload
      def product_id
        extract_remote_id(product_ref)
      end

      # @return [Numeric, nil] quantity ordered
      def quantity
        attributes['quantity']
      end

      # @return [Numeric, nil] unit price
      def unit_price
        attributes['unit_price']
      end

      # @return [Numeric, nil] line amount
      def amount
        attributes['amount']
      end

      # @return [String, nil] line description
      def description
        attributes['description']
      end

      belongs_to :sale, class_name: 'Fulfil::Remote::Sale', foreign_key: :sale_ref
    end
  end
end
