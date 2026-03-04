# frozen_string_literal: true

require 'test_helper'

module Fulfil
  class RemoteResourceTest < Minitest::Test
    class TestRemoteResource < RemoteResource
      ATTRIBUTES = %w[id name].freeze
      FULFIL_MODEL_NAME = 'test.model'

      def self.from_fulfil(response)
        new(id: response['id'], name: response['name'])
      end

      def name
        attributes['name']
      end
    end

    FakeModel = Struct.new(:rows, :captured_kwargs) do
      def search(**kwargs)
        self.captured_kwargs = kwargs
        rows
      end
    end

    def test_all_maps_results
      model = FakeModel.new([{ 'id' => 1, 'name' => 'A' }, { 'id' => 2, 'name' => 'B' }])

      resources = TestRemoteResource.stub(:fulfil_model, model) do
        TestRemoteResource.all(ids: [1, 2], domain: [['active', '=', true]])
      end

      expected_query = {
        domain: [['active', '=', true], ['id', 'in', [1, 2]]],
        fields: %w[id name]
      }

      assert_equal expected_query, model.captured_kwargs
      assert_equal 2, resources.size
      assert_equal 'A', resources.first.name
    end

    def test_find_returns_resource
      model = FakeModel.new([{ 'id' => 9, 'name' => 'Widget' }])

      resource = TestRemoteResource.stub(:fulfil_model, model) { TestRemoteResource.find(9) }

      assert_equal({ domain: [['id', '=', 9]], fields: %w[id name] }, model.captured_kwargs)
      assert_equal 9, resource.id
      assert_equal 'Widget', resource.name
    end

    def test_find_raises_not_found
      model = FakeModel.new([])

      assert_raises(RemoteResource::ResourceNotFound) do
        TestRemoteResource.stub(:fulfil_model, model) { TestRemoteResource.find(404) }
      end
    end

    def test_persisted
      assert_predicate TestRemoteResource.new(id: 12), :persisted?
      refute_predicate TestRemoteResource.new, :persisted?
    end

    def test_equality
      one = TestRemoteResource.new(id: 7)
      two = TestRemoteResource.new(id: 7)
      three = TestRemoteResource.new(id: 8)

      assert_equal one, two
      refute_equal one, three
    end
  end
end
