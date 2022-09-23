# frozen_string_literal: true

require 'dotenv/load'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'fulfil'

require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

require 'minitest/ci' if ENV['CI']
require 'minitest/autorun'

require 'support/fulfil_helper'
require 'support/configuration_helper'
require 'support/custom_assertions'

class Minitest::Test
  include CustomAssertions
  include FulfilHelper
end
