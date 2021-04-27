# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'fulfil'

require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

require 'minitest/ci' if ENV['CI']
require 'minitest/autorun'

require 'support/fulfil_helper'
