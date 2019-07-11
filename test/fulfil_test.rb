require "test_helper"

class FulfilTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Fulfil::VERSION
  end
end
