# frozen_string_literal: true

# By convention, Bundler will attempt to load the `fulfil/io.rb` or `fulfil-io.rb` file.
# See https://guides.rubygems.org/name-your-gem/
#
# Due to this convention, the developer using this gem will need to manually
# require fulfil in the Gemfile or anywhere else in their application.
#
# To make it a little bit more convenient, we've added the `fulfil-io.rb` file
# that is loaded by default by Bundler and it's only job is to include all of
# the other gem files.

require 'fulfil'
