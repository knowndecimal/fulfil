# frozen_string_literal: true

require 'webmock/minitest'

module FulfilHelper
  DEFAULT_HEADERS = {
    'Host' => "#{ENV.fetch('FULFIL_SUBDOMAIN')}.fulfil.io"
  }.freeze

  def stub_fulfil_get(path, fixture, status_code = 200)
    stub_request(:get, "https://#{ENV.fetch('FULFIL_SUBDOMAIN')}.fulfil.io/api/v2/model/#{path}")
      .with(headers: valid_request_headers)
      .to_return(status: status_code, body: load_fixture(fixture), headers: valid_response_headers)
  end

  def stub_fulfil_put(path, fixture, body, status_code = 200)
    stub_request(:put, "https://#{ENV.fetch('FULFIL_SUBDOMAIN')}.fulfil.io/api/v2/model/#{path}")
      .with(headers: valid_request_headers, body: body)
      .to_return(status: status_code, body: load_fixture(fixture), headers: valid_response_headers)
  end

  # Found at https://blog.arkency.com/recording-real-requests-with-webmock/
  def allow_and_print_real_requests_globally!
    WebMock.allow_net_connect!

    WebMock.after_request do |request_signature, response|
      stubbing_instructions = WebMock::RequestSignatureSnippet
                              .new(request_signature)
                              .stubbing_instructions

      parsed_body = JSON.parse(response.body)
      puts '===== outgoing request ======================='
      puts stubbing_instructions
      puts
      puts 'parsed body:'
      puts
      pp parsed_body
      puts '=============================================='
      puts
    end
  end

  private

  def valid_request_headers
    if ENV.key?('FULFIL_API_KEY')
      valid_request_headers_with_api_key
    else
      valid_request_headers_with_auth_token
    end
  end

  def valid_response_headers
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  def valid_request_headers_with_auth_token
    DEFAULT_HEADERS.merge(
      'Authorization' => "Bearer #{ENV.fetch('FULFIL_OAUTH_TOKEN')}"
    )
  end

  def valid_request_headers_with_api_key
    DEFAULT_HEADERS.merge(
      'X-Api-Key' => ENV.fetch('FULFIL_API_KEY')
    )
  end

  def load_fixture(name)
    File.read(File.dirname(__FILE__) + "/../fixtures/#{name}.json")
  end
end
