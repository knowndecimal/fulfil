# frozen_string_literal: true

require 'minitest/autorun'

class ResponseHandlerTest < Minitest::Test
  ALL_HTTP_STATUS_CODES = %w[
    100 101 102 200 201 202 203 204 205 206 207 208 226 300 301 302 303 304 305
    307 308 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416
    417 421 422 423 424 426 428 429 431 500 501 502 503 504 505 506 507 508 510
    511
  ].freeze

  # The `ResponseMock` mimicks the `Http::Response` class.
  class ResponseMock
    def initialize(status_code:, parsed_body: {})
      @status_code = status_code
      @parsed_body = parsed_body
    end

    def body
      @parsed_body
    end

    def code
      @status_code
    end

    def headers
      { 'Response-Type': 'application/json' }
    end

    def status
      @status_code.to_s
    end

    def parse
      @parsed_body
    end
  end

  ALL_HTTP_STATUS_CODES.each do |http_status_code|
    status_code = http_status_code.to_i
    response = ResponseMock.new(status_code: status_code)

    if status_code >= 400
      expected_exception =
        if Fulfil::ResponseHandler::HTTP_ERROR_CODES.key?(status_code)
          Fulfil::ResponseHandler::HTTP_ERROR_CODES[status_code]
        else
          Fulfil::HttpError
        end

      define_method(:"test_http_status_code_#{status_code}_raises_exception") do
        error_message = assert_raises expected_exception do
          Fulfil::ResponseHandler.new(response).verify!
        end

        assert_kind_of Fulfil::HttpError, error_message
      end
    else
      define_method(:"test_http_status_code_#{status_code}_raises_no_exception") do
        assert Fulfil::ResponseHandler.new(response).verify!
      end
    end
  end

  def test_prefers_fulfil_error_payload_message_and_metadata
    payload = {
      'type' => 'UserError',
      'code' => 'E1000',
      'message' => "Cannot create record with state 'open'. Allowed states: draft",
      'description' => ''
    }

    response = ResponseMock.new(status_code: 400, parsed_body: payload)

    error = assert_raises(Fulfil::HttpError::BadRequest) do
      Fulfil::ResponseHandler.new(response).verify!
    end

    assert_equal "[E1000] UserError: Cannot create record with state 'open'. Allowed states: draft", error.message
    assert_equal payload, error.metadata[:parsed_body]
    assert_equal 'E1000', error.metadata[:code]
    assert_equal 'UserError', error.metadata[:type]
  end

  def test_falls_back_to_generic_message_when_payload_is_empty
    response = ResponseMock.new(status_code: 400, parsed_body: {})

    error = assert_raises(Fulfil::HttpError::BadRequest) do
      Fulfil::ResponseHandler.new(response).verify!
    end

    assert_equal 'Fulfil request failed (HTTP 400)', error.message
  end
end
