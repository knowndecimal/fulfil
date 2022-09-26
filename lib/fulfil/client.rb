# frozen_string_literal: true

require 'http'
require 'logger'
require 'fulfil/response_parser'

module Fulfil
  SUBDOMAIN = ENV.fetch('FULFIL_SUBDOMAIN', nil)
  API_KEY = ENV.fetch('FULFIL_API_KEY', nil)

  class Client
    class InvalidClientError < StandardError
      def message
        'Client is not configured correctly.'
      end
    end

    class NotAuthorizedError < StandardError; end

    class UnknownHTTPError < StandardError; end

    class ConnectionError < StandardError; end

    class ResponseError < StandardError; end

    def initialize(subdomain: SUBDOMAIN, token: oauth_token, headers: { 'X-API-KEY' => API_KEY }, debug: false)
      @subdomain = subdomain
      @token = token
      @debug = debug
      @headers = headers
      @headers.delete('X-API-KEY') if @token

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

    def search(model:, domain:, offset: nil, limit: 100, sort: nil, fields: %w[id])
      uri = URI("#{model_url(model: model)}/search_read")
      body = [domain, offset, limit, sort, fields]

      results = request(verb: :put, endpoint: uri, json: body)
      parse(results: results)
    end

    def count(model:, domain:)
      uri = URI("#{model_url(model: model)}/search_count")
      body = [domain]

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

    def request(endpoint:, verb: :get, **args)
      raise InvalidClientError if invalid?

      response = client.request(verb, endpoint, args)
      Fulfil::ResponseHandler.new(response).verify!

      response.parse
    rescue HTTP::Error => e
      puts e
      raise UnknownHTTPError, 'Unhandled HTTP error encountered'
    rescue HTTP::ConnectionError => e
      puts "Couldn't connect"
      raise ConnectionError, "Can't connect to #{base_url}"
    rescue HTTP::ResponseError => e
      raise ResponseError, "Can't process response: #{e}"
      []
    # If configured, the client will wait whenever the `RateLimitExceeded` exception
    # is raised. Check `Fulfil::Configuration` for more details.
    rescue RateLimitExceeded => e
      raise e unless config.retry_on_rate_limit?

      sleep config.retry_on_rate_limit_wait
      retry
    end

    def client
      client = HTTP.use(logging: @debug ? { logger: Logger.new($stdout) } : {})
      client = client.auth("Bearer #{@token}") if @token
      client.headers(@headers)
    end

    def config
      Fulfil.config
    end
  end
end
