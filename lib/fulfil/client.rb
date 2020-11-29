# frozen_string_literal: true

require 'http'
require 'logger'
require 'fulfil/response_parser'

module Fulfil
  SUBDOMAIN = ENV['FULFIL_SUBDOMAIN']
  API_KEY = ENV['FULFIL_API_KEY']
  OAUTH_TOKEN = ENV['FULFIL_TOKEN']

  class Client
    def initialize(subdomain: SUBDOMAIN, token: OAUTH_TOKEN, headers: { 'X-API-KEY' => API_KEY }, debug: false)
      @subdomain = subdomain
      @token = token
      @debug = debug
      @headers = headers
      @headers.delete('X-API-KEY') if @token
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

    def put(model:, id:, endpoint: nil, body: {})
      uri = URI(model_url(model: model, id: id, endpoint: endpoint))

      result = request(verb: :put, endpoint: uri, json: body)
      parse(result: result)
    end

    private

    def parse(result: nil, results: [])
      if result.present?
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

    def base_url
      "https://#{@subdomain}.fulfil.io/api/v2/model"
    end

    def model_url(model:, id: nil, endpoint: nil)
      [base_url, model, id, endpoint].compact.join('/')
    end

    def request(verb: :get, endpoint:, **args)
      response = client.request(verb, endpoint, args)

      if response.status.ok? || response.status.created?
        response.parse
      elsif response.code == 401
        raise StandardError, 'Not authorized'
      else
        puts response.body.to_s
        raise Error, 'Error encountered while processing response:'
      end
    rescue HTTP::Error => e
      puts e
      raise Error, 'Unhandled HTTP error encountered'
    rescue HTTP::ConnectionError => e
      puts "Couldn't connect"
      raise Error, "Can't connect to #{base_url}"
    rescue HTTP::ResponseError => ex
      raise Error, "Can't process response: #{ex}"
      []
    end

    def client
      return @client if defined?(@client)

      @client = HTTP.persistent(base_url).use(logging: @debug ? { logger: Logger.new(STDOUT) } : {})
      @client = @client.auth("Bearer #{@token}") if @token
      @client = @client.headers(@headers)
      @client
    end
  end
end
