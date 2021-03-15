# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'fulfil'

require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

require 'minitest/ci' if ENV['CI']
require 'minitest/autorun'

require 'webmock/minitest'

def load_fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}.json")
end

def stub_fulfil_get(path, fixture, status_code = 200)
  stub_request(:get, "https://fulfil-test.fulfil.io/api/v2/model/#{path}")
    .with(headers: valid_request_headers)
    .to_return(status: status_code, body: load_fixture(fixture), headers: valid_response_headers)
end

def stub_fulfil_put(path, fixture, body, status_code = 200)
  stub_request(:put, "https://fulfil-test.fulfil.io/api/v2/model/#{path}")
    .with(headers: valid_request_headers, body: body)
    .to_return(status: status_code, body: load_fixture(fixture), headers: valid_response_headers)
end

def valid_request_headers
  {
    'Authorization' => 'Bearer user-token',
    'Connection' => 'Keep-Alive',
    'Host' => 'fulfil-test.fulfil.io',
    'User-Agent' => 'http.rb/4.4.1'
  }
end

def valid_response_headers
  {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
end
