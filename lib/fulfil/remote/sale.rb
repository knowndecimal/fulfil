# frozen_string_literal: true

module Fulfil
  module Remote
    # Fulfil-backed representation of a sale resource.
    #
    # @see Fulfil::Remote::Resource
    class Sale < Resource
      # Fields requested from Fulfil for sale reads.
      ATTRIBUTES = %w[
        id number reference rec_name state party lines total_amount create_date
      ].freeze

      # Fulfil model name.
      FULFIL_MODEL_NAME = 'sale.sale'

      # Builds a sale instance from a raw Fulfil response row.
      #
      # @param raw_sale [Hash] serialized sale row from Fulfil
      # @return [Fulfil::Remote::Sale]
      def self.from_fulfil(raw_sale)
        new(
          id: raw_sale['id'],
          number: raw_sale['number'],
          reference: raw_sale['reference'],
          rec_name: raw_sale['rec_name'],
          state: raw_sale['state'],
          party: raw_sale['party'],
          line_ids: raw_sale['lines'] || [],
          total_amount: raw_sale['total_amount'],
          created_at: raw_sale['create_date']
        )
      end

      # @return [String, nil] Fulfil sale number (e.g. SO12345)
      def number
        attributes['number']
      end

      # @return [String, nil] external/reference identifier
      def reference
        attributes['reference']
      end

      # @return [String, nil] Fulfil record display name
      def rec_name
        attributes['rec_name']
      end

      # @return [String, nil] current state of the sale
      def state
        attributes['state']
      end

      # @return [Integer, Array, nil] Fulfil party reference
      def party
        attributes['party']
      end

      # @return [Array<Integer>] sale line IDs linked to this sale
      def line_ids
        attributes['line_ids'] || []
      end

      # @return [Object, nil] total amount payload from Fulfil
      def total_amount
        attributes['total_amount']
      end

      # @return [Object, nil] create date payload from Fulfil
      def created_at
        attributes['created_at']
      end

      has_many :lines, class_name: 'Fulfil::Remote::SaleLine', ids_key: :line_ids
    end
  end
end
