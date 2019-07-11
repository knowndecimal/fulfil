$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "fulfil"

require 'minitest/reporters'
Minitest::Reporters.use!

require 'minitest/ci' if ENV['CI']
require "minitest/autorun"
