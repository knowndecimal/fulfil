# frozen_string_literal: true

require 'test_helper'

module Fulfil
  module Remote
    class SaleTest < Minitest::Test
      def test_from_fulfil_maps_expected_attributes
        raw_sale = {
          'id' => 213_112,
          'number' => 'SO79797',
          'reference' => 'R230530021',
          'rec_name' => 'SO79797 (R230530021)',
          'state' => 'done',
          'party' => 118_637,
          'lines' => [217_937, 217_938],
          'total_amount' => { 'decimal' => '60.00' },
          'create_date' => { 'iso_string' => '2018-04-18T20:20:13.862082' }
        }

        sale = Sale.from_fulfil(raw_sale)

        assert_equal 213_112, sale.id
        assert_equal 'SO79797', sale.number
        assert_equal 'R230530021', sale.reference
        assert_equal 'done', sale.state
        assert_equal 118_637, sale.party
        assert_equal [217_937, 217_938], sale.line_ids
        assert_equal({ 'decimal' => '60.00' }, sale.total_amount)
        assert_equal({ 'iso_string' => '2018-04-18T20:20:13.862082' }, sale.created_at)
      end

      def test_lines_loads_sale_lines_by_ids
        sale = Sale.new(id: 1, line_ids: [10, 11])

        SaleLine.stub(:all, %i[one two]) do
          assert_equal %i[one two], sale.lines
        end
      end

      def test_lines_returns_empty_array_when_no_ids
        sale = Sale.new(id: 1, line_ids: [])

        assert_equal [], sale.lines
      end
    end
  end
end
