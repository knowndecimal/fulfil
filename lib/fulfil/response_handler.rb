# frozen_string_literal: true

module Fulfil
  # The `Fulfil::ResponseHandler` is parses the HTTP response from Fulfil. If it
  # encounters an HTTP status code that indicates an error, it will raise an internal
  # exception that the consumer can catch.
  #
  # @example
  #   Fulfil::ResponseHandler.new(@response).verify!
  #   => { id: 100 }
  #
  #   Fulfil::ResponseHandler.new(@response).verify!
  #   => Fulfil::Error::BadRequest
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
      return true unless HTTP_ERROR_CODES.key?(@status_code)

      raise HTTP_ERROR_CODES[@status_code].new(
        response_body['error_description'],
        {
          body: @response.body,
          headers: @response.headers,
          status: @response.status
        }
      )
    end

    private

    def response_body
      @response_body ||= @response.parse
    end
  end
end
