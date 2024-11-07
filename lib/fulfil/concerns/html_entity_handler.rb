# frozen_string_literal: true

module Fulfil
  module Concerns
    module HtmlEntityHandler
      private

      def with_disabled_html_entities
        disable_escape_html_entities
        yield
      ensure
        enable_escape_html_entities
      end

      def disable_escape_html_entities
        return unless defined?(ActiveSupport) && ActiveSupport.respond_to?(:escape_html_entities_in_json=)

        ActiveSupport.escape_html_entities_in_json = false
      end

      def enable_escape_html_entities
        return unless defined?(ActiveSupport) && ActiveSupport.respond_to?(:escape_html_entities_in_json=)

        ActiveSupport.escape_html_entities_in_json = true
      end
    end
  end
end
