# frozen_string_literal: true

# Allows temporary setting a configuration option during tests. Switches back
# to the original configuration after running the test.
def with_fulfil_config(&block)
  previous_config = Fulfil.config
  Fulfil.configure { |config| block.call(config) }
ensure
  Fulfil.config = previous_config
end
