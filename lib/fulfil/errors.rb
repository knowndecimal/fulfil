# frozen_string_literal: true

module Fulfil
  class Error < StandardError; end

  # The `Fulfil::HttpError` is raised whenever an API request returns a non-200 HTTP status code.
  # See `Fulfil::ResponseHandler` for more information.
  class HttpError < Error
    attr_reader :metadata

    def initialize(message, metadata = {})
      @metadata = metadata
      super(message)
    end

    class BadRequest < HttpError; end
    class AuthorizationRequired < HttpError; end
    class PaymentRequired < HttpError; end
    class Forbidden < HttpError; end
    class NotFound < HttpError; end
    class MethodNotAllowed < HttpError; end
    class NotAccepted < HttpError; end
    class UnprocessableEntity < HttpError; end
    class TooManyRequests < HttpError; end
    class InternalServerError < HttpError; end
  end
end
