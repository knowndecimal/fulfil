module Fulfil
  class Model
    attr_reader :model_name

    def initialize(client:, model_name:)
      @client = client
      @model_name = model_name
    end

    # Delegate this to the client, including the model_name so we don't have to
    # type it every time.
    def find(model: model_name, id:)
      @client.find(model: model, id: id)
    end

    # Delegate this to the client, including the model_name so we don't have to
    # type it every time.
    def search(
      model: model_name,
      domain:,
      fields: %w[id rec_name],
      limit: nil,
      offset: nil,
      sort: nil
    )
      @client.search(
        model: model,
        domain: domain,
        fields: fields,
        limit: limit,
        offset: offset,
        sort: sort
      )
    end

    def attributes
      results = @client.search(model: model_name, domain: [], limit: 1)
      @client.find(model: model_name, id: results.first.dig('id'))
    end

    def fetch_associated(models:, association_name:, source_key:, fields:)
      source_keys = source_key.split('.')
      associated_ids =
        models.map { |model| model.dig(*source_keys) }.flatten.compact.uniq

      return if associated_ids.none?

      associated_models =
        @client.find(
          model: association_name, ids: associated_ids, fields: fields
        )

      associated_models_by_id = associated_models.map { |m| [m['id'], m] }.to_h

      models.each do |model|
        filtered_models =
          model.dig(*source_keys).map { |id| associated_models_by_id[id] }

        if source_keys.length > 1
          model.dig(*source_keys[0..-2]).store(
            source_keys.last,
            filtered_models
          )
        else
          model[source_keys.first] = filtered_models
        end
      end
    end
  end
end
