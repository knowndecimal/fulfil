require 'minitest/autorun'
require 'fulfil/response_parser'

class ResponseParserTest < Minitest::Test
  def setup
    @sample = {
      "amount" => {
        "__class__" => "Decimal",
        "decimal" => 100.00,
      },
      "sale" => 12345,
      "sale.amount" => 100.00,
      "sale.party" => 54321,
      "sale.party.email" => "test@example.com",
      "sale.party.name" => "Lester McTester",
    }

    @expected = {
      "amount" => 100.00,
      "sale" => {
        "amount" => 100.00,
        "id" => 12345,
        "party" => {
          "id" => 54321,
          "email" => "test@example.com",
          "name" => "Lester McTester",
        }
      }
    }
  end

  def test_parsing
    result = Fulfil::ResponseParser.parse(item: @sample)

    assert_equal @expected['amount'], result['amount']

    assert_kind_of Hash, result.dig('sale')
    assert_equal 100.00, result.dig('sale', 'amount')
    assert_equal 12345, result.dig('sale', 'id')

    assert_kind_of Hash, result.dig('sale', 'party')
    assert_equal 54321, result.dig('sale', 'party', 'id')
    assert_equal "test@example.com", result.dig('sale', 'party', 'email')

    assert_equal @expected, result
  end

  def test_unhandled_type
    bad_value = {
      "unknowndatatype" => {
        "__class__" => "unknown",
        "decimal" => 100.00,
      }
    }

    assert_raises 'Fulfil::ResponseParser::UnhandledTypeError' do
      Fulfil::ResponseParser.parse(item: bad_value)
    end
  end
end
