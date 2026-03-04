# frozen_string_literal: true

module Fulfil
  module Remote
    # Base class for domain-specific resources loaded from Fulfil.
    #
    # Subclasses are expected to define:
    # - `FULFIL_MODEL_NAME` (String): Fulfil model name, e.g. `"product.product"`
    # - `ATTRIBUTES` (Array<String>): Fulfil fields used for read operations
    # - `.from_fulfil(response)` (Class method): mapper from raw Fulfil hash to instance
    class Resource
      # Raised when a requested resource cannot be found in Fulfil.
      class ResourceNotFound < StandardError; end

      # @return [Hash<String, Object>] raw attributes stored by this instance
      attr_reader :attributes

      # @param attributes [Hash] initial attributes for the resource
      # @return [Fulfil::Remote::Resource]
      def initialize(attributes = {})
        @attributes = attributes.transform_keys(&:to_s)
      end

      # @return [Object, nil] resource id from attributes
      def id
        attributes['id']
      end

      # @return [Boolean] whether this object has an id
      def persisted?
        !id.nil?
      end

      # @param other [Object] object to compare
      # @return [Boolean] true when both objects expose the same id
      def ==(other)
        other.respond_to?(:id) && id == other.id
      end

      class << self
        # Fetches resources from Fulfil.
        #
        # @param ids [Array<Integer>] optional id filter
        # @param domain [Array<Array>] additional Fulfil domain filters
        # @return [Array<Fulfil::Remote::Resource>]
        def all(ids: [], domain: [])
          query_domain = domain.dup
          query_domain << ['id', 'in', ids] unless ids.empty?

          fulfil_model
            .search(domain: query_domain, fields: self::ATTRIBUTES)
            .map { |raw_resource| from_fulfil(raw_resource) }
        end

        # Finds a single resource by id.
        #
        # @param id [Integer] Fulfil resource id
        # @return [Fulfil::Remote::Resource]
        # @raise [Fulfil::Remote::Resource::ResourceNotFound]
        def find(id)
          response = fulfil_model.search(domain: [['id', '=', id]], fields: self::ATTRIBUTES).first
          raise ResourceNotFound if response.nil?

          from_fulfil(response)
        end

        # @return [Fulfil::Model] model wrapper configured for the subclass
        def fulfil_model
          @fulfil_model ||= Fulfil::Model.new(client: FulfilClient, model_name: self::FULFIL_MODEL_NAME)
        end

        # Converts a raw Fulfil response row into a resource instance.
        #
        # @param _response [Hash]
        # @return [Fulfil::Remote::Resource]
        # @raise [NotImplementedError] when not implemented by subclass
        def from_fulfil(_response)
          raise NotImplementedError
        end
      end
    end
  end
end
