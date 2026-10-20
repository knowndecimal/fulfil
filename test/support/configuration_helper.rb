# frozen_string_literal: true

# Allows temporary setting a configuration option during tests. Switches back
# to the original configuration after running the test.
def with_fulfil_config(&block)
  Fulfil.configure(&block)
ensure
  Fulfil.config = Fulfil::Configuration.new
end
