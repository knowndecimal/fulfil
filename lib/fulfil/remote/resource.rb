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

      private

      # Extracts an id from a Fulfil reference payload.
      #
      # Fulfil references are often returned as either:
      # - Integer id
      # - Array payload like [id, rec_name]
      #
      # @param value [Integer, Array, nil]
      # @return [Integer, nil]
      def extract_remote_id(value)
        value.is_a?(Array) ? value.first : value
      end

      class << self
        # Defines a has_many association loaded by a list of remote ids.
        #
        # @param name [Symbol] association method name
        # @param class_name [String] fully qualified class name
        # @param ids_key [String, Symbol] local attribute key with id list
        # @return [void]
        # rubocop:disable Naming/PredicatePrefix
        def has_many(name, class_name:, ids_key:)
          define_method(name) do
            ids = attributes[ids_key.to_s] || []
            return [] if ids.empty?

            self.class.constantize(class_name).all(ids: ids)
          end
        end
        # rubocop:enable Naming/PredicatePrefix

        # Defines a belongs_to association loaded from a Fulfil reference payload.
        #
        # @param name [Symbol] association method name
        # @param class_name [String] fully qualified class name
        # @param foreign_key [String, Symbol] local attribute key containing reference
        # @return [void]
        def belongs_to(name, class_name:, foreign_key:)
          define_method(name) do
            remote_reference = attributes[foreign_key.to_s]
            remote_id = extract_remote_id(remote_reference)
            return nil if remote_id.nil?

            self.class.constantize(class_name).find(remote_id)
          end
        end

        # Resolves a constant from a fully qualified class name.
        #
        # @param class_name [String]
        # @return [Class]
        def constantize(class_name)
          class_name.split('::').reject(&:empty?).reduce(Object) { |scope, const| scope.const_get(const) }
        end

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

        # @return [Fulfil::Client] client used for remote resource requests
        def client
          @client ||= Fulfil::Client.new
        end

        # Overrides the client used for remote resource requests.
        #
        # @param client [Fulfil::Client]
        # @return [Fulfil::Client]
        def client=(client)
          @client = client
          @fulfil_model = nil
        end

        # @return [Fulfil::Model] model wrapper configured for the subclass
        def fulfil_model
          @fulfil_model ||= Fulfil::Model.new(client: client, model_name: self::FULFIL_MODEL_NAME)
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
