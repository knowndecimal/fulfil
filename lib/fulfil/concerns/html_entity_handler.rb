# frozen_string_literal: true

module Fulfil
  module Concerns
    # Handles HTML entity escaping in JSON serialization
    # This module provides methods to temporarily disable and re-enable HTML entity escaping
    # when working with ActiveSupport's JSON encoding, which is particularly useful when
    # dealing with special characters in API requests.
    #
    # @example
    #   class MyParser
    #     include Concerns::HtmlEntityHandler
    #
    #     def parse_data
    #       with_disabled_html_entities do
    #         # Your code here that needs HTML entities disabled
    #       end
    #     end
    #   end
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
