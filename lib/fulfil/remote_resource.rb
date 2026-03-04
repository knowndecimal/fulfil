# frozen_string_literal: true

module Fulfil
  class RemoteResource
    class ResourceNotFound < StandardError; end

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes.transform_keys(&:to_s)
    end

    def id
      attributes['id']
    end

    def persisted?
      !id.nil?
    end

    def ==(other)
      other.respond_to?(:id) && id == other.id
    end

    class << self
      def all(ids: [], domain: [])
        query_domain = domain.dup
        query_domain << ['id', 'in', ids] unless ids.empty?

        fulfil_model
          .search(domain: query_domain, fields: self::ATTRIBUTES)
          .map { |raw_resource| from_fulfil(raw_resource) }
      end

      def find(id)
        response = fulfil_model.search(domain: [['id', '=', id]], fields: self::ATTRIBUTES).first
        raise ResourceNotFound if response.nil?

        from_fulfil(response)
      end

      def fulfil_model
        @fulfil_model ||= Fulfil::Model.new(client: FulfilClient, model_name: self::FULFIL_MODEL_NAME)
      end

      def from_fulfil(_response)
        raise NotImplementedError
      end
    end
  end
end
