# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.start do
  formatter SimpleCov::Formatter::JSONFormatter
end
