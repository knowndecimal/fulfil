# frozen_string_literal: true

require 'http'
require 'json'
require 'logger'
require 'fulfil/response_parser'
require 'fulfil/domain_parser'

module Fulfil
  SUBDOMAIN = ENV.fetch('FULFIL_SUBDOMAIN', nil)
  API_KEY = ENV.fetch('FULFIL_API_KEY', nil)

  class Client
    class InvalidClientError < StandardError
      def message
        super || 'Client is not configured correctly.'
      end
    end

    class NotAuthorizedError < StandardError; end

    class UnknownHTTPError < StandardError; end

    class ConnectionError < StandardError; end

    class ResponseError < StandardError; end

    def initialize(subdomain: SUBDOMAIN, token: oauth_token, api_key: API_KEY, headers: nil, debug: false)
      @subdomain = subdomain
      @debug = debug

      normalized_api_key = api_key || headers&.[]('X-API-KEY') || headers&.[]('X-Api-Key')

      if !token.to_s.empty?
        @token = token
      elsif !normalized_api_key.to_s.empty?
        @api_key = normalized_api_key
      else
        raise InvalidClientError, 'No token or API key provided.'
      end

      raise InvalidClientError if invalid?
    end

    def invalid?
      @subdomain.nil? || @subdomain.empty?
    end

    def valid?
      !invalid?
    end

    def find(model:, ids: [], id: nil, fields: %w[id rec_name])
      if ids.any?
        find_many(model: model, ids: ids, fields: fields)
      elsif !id.nil?
        find_one(model: model, id: id)
      else
        raise
      end
    end

    def find_one(model:, id:)
      raise 'missing id' if id.nil?

      uri = URI("#{model_url(model: model)}/#{id}")
      result = request(endpoint: uri)
      parse(result: result)
    end

    def find_many(model:, ids:, fields: nil)
      raise 'missing ids' if ids.empty?

      uri = URI("#{model_url(model: model)}/read")
      results = request(verb: :put, endpoint: uri, json: [ids, fields])
      parse(results: results)
    end

    def search(model:, domain:, **options)
      context = options.fetch(:context, nil)
      uri = model_uri(model: model, endpoint: 'search_read', context: context)
      parsed_domain = Fulfil::DomainParser.new(domain).parsed
      body = [
        parsed_domain,
        options.fetch(:offset, nil),
        options.fetch(:limit, 100),
        options.fetch(:sort, nil),
        options.fetch(:fields, %w[id])
      ]

      results = request(verb: :put, endpoint: uri, json: body)
      parse(results: results)
    end

    def count(model:, domain:, context: nil)
      uri = model_uri(model: model, endpoint: 'search_count', context: context)
      parsed_domain = Fulfil::DomainParser.new(domain).parsed
      body = [parsed_domain]

      request(verb: :put, endpoint: uri, json: body)
    end

    def post(model:, body: {})
      uri = URI(model_url(model: model))

      results = request(verb: :post, endpoint: uri, json: body)
      parse(results: results)
    end

    def put(model: nil, id: nil, endpoint: nil, body: {})
      uri = URI(model_url(model: model, id: id, endpoint: endpoint))

      result = request(verb: :put, endpoint: uri, json: body)

      parse(result: result)
    end

    def delete(model:, id:)
      uri = URI(model_url(model: model, id: id))

      result = request(verb: :delete, endpoint: uri)
      parse(result: result)
    end

    def interactive_report(endpoint:, body: nil)
      uri = URI("#{base_url}/model/#{endpoint}")
      result = request(verb: :put, endpoint: uri, json: body)
      parse(result: result)
    end

    private

    def oauth_token
      if ENV['FULFIL_TOKEN']
        puts "You're using an deprecated environment variable. Please update your " \
             'FULFIL_TOKEN to FULFIL_OAUTH_TOKEN.'
      end

      ENV['FULFIL_OAUTH_TOKEN'] || ENV.fetch('FULFIL_TOKEN', nil)
    end

    def parse(result: nil, results: [])
      if result
        parse_single(result: result)
      else
        parse_multiple(results: results)
      end
    end

    def parse_single(result:)
      Fulfil::ResponseParser.parse(item: result)
    end

    def parse_multiple(results:)
      results.map { |result| Fulfil::ResponseParser.parse(item: result) }
    end

    def domain
      "https://#{@subdomain}.fulfil.io"
    end

    def base_url
      [domain, 'api', 'v2'].join('/')
    end

    def model_url(model:, id: nil, endpoint: nil)
      [base_url, 'model', model, id, endpoint].compact.join('/')
    end

    def model_uri(model:, id: nil, endpoint: nil, context: nil)
      uri = URI(model_url(model: model, id: id, endpoint: endpoint))
      return uri if context.nil?

      uri.query = URI.encode_www_form(context: context_query_value(context))
      uri
    end

    def context_query_value(context)
      context.is_a?(String) ? context : context.to_json
    end

    def request(endpoint:, verb: :get, **args)
      attempts = 0

      begin
        response = client.request(verb, endpoint, args)
        Fulfil::ResponseHandler.new(response).verify!

        response.parse
      rescue HTTP::ConnectionError => e
        raise ConnectionError, "Can't connect to #{base_url}"
      rescue HTTP::ResponseError => e
        raise ResponseError, "Can't process response: #{e}"
      rescue HTTP::Error => e
        raise UnknownHTTPError, 'Unhandled HTTP error encountered'
      # If configured, the client will wait whenever the `RateLimitExceeded` exception
      # is raised. Check `Fulfil::Configuration` for more details.
      rescue RateLimitExceeded => e
        raise e unless config.retry_on_rate_limit?

        attempts += 1
        raise e if attempts > config.retry_on_rate_limit_max_attempts

        sleep(rate_limit_retry_wait)
        retry
      end
    end

    def rate_limit_retry_wait
      Fulfil::RateLimitRetryWait.call(config: config, reset_at: Fulfil.rate_limit.resets_at)
    end

    def client
      client = HTTP.use(logging: @debug ? { logger: config.logger } : {})
      client = client.auth("Bearer #{@token}") if @token
      client = client.headers({ 'X-API-KEY': @api_key }) if @api_key
      client
    end

    def config
      Fulfil.config
    end
  end
end
