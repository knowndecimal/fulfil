require 'test_helper'

module Fulfil
  class ClientTest < MiniTest::Test
    def test_invalid_client
      assert_raises('InvalidClientError') { Fulfil::Client.new(subdomain: nil, token: nil) }
    end
  end
end
