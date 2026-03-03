# frozen_string_literal: true

module Fulfil
  # The `Fulfil::ResponseHandler` parses the HTTP response from Fulfil. If it
  # encounters an HTTP status code that indicates an error, it raises an internal
  # exception that the consumer can catch.
  class ResponseHandler
    HTTP_ERROR_CODES = {
      400 => Fulfil::HttpError::BadRequest,
      401 => Fulfil::HttpError::AuthorizationRequired,
      402 => Fulfil::HttpError::PaymentRequired,
      403 => Fulfil::HttpError::Forbidden,
      404 => Fulfil::HttpError::NotFound,
      405 => Fulfil::HttpError::MethodNotAllowed,
      406 => Fulfil::HttpError::NotAccepted,
      422 => Fulfil::HttpError::UnprocessableEntity,
      429 => Fulfil::HttpError::TooManyRequests,
      500 => Fulfil::HttpError::InternalServerError
    }.freeze

    def initialize(response)
      @response = response
      @status_code = response.code
    end

    def verify!
      verify_rate_limits!
      verify_http_status_code!
    end

    private

    def verify_rate_limits!
      Fulfil.rate_limit.analyse!(@response.headers)
    end

    def verify_http_status_code!
      return true unless @status_code >= 400

      payload = response_body
      raise HTTP_ERROR_CODES.fetch(@status_code, Fulfil::HttpError).new(
        response_error_message(payload),
        response_error_metadata(payload)
      )
    end

    def response_error_message(payload)
      body = payload.is_a?(Hash) ? payload : {}

      code = body['code']
      type = body['type']
      message = first_present(
        body['error_description'],
        body.dig('error', 'message'),
        body['message'],
        body['description'],
        body['detail'],
        body.dig('errors', 0, 'message')
      )

      return "Fulfil request failed (HTTP #{@status_code})" if message.nil?

      message_parts = []
      message_parts << "[#{code}]" if present?(code)
      message_parts << "#{type}:" if present?(type)
      message_parts << message
      message_parts.join(' ')
    end

    def response_error_metadata(payload)
      body = payload.is_a?(Hash) ? payload : {}

      {
        body: @response.body,
        parsed_body: payload,
        headers: @response.headers,
        status: @response.status,
        code: body['code'],
        type: body['type'],
        message: body['message'],
        description: body['description']
      }
    end

    def response_body
      @response_body ||= @response.parse
    end

    def present?(value)
      !(value.nil? || value.to_s.strip.empty?)
    end

    def first_present(*values)
      values.find { |value| present?(value) }
    end
  end
end
