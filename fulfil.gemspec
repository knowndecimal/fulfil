# frozen_string_literal: true

require_relative 'lib/fulfil/version'

Gem::Specification.new do |spec|
  spec.name          = 'fulfil-io'
  spec.version       = Fulfil::VERSION
  spec.authors       = ['Chris Moore', 'Kat Fairbanks']
  spec.email         = ['chris@knowndecimal.com']

  spec.summary       = 'Interact with the Fulfil.io API'
  spec.homepage      = 'https://github.com/knowndecimal/fulfil'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # To include hidden files from the lib/ folder you need to use the File::FNM_DOTMATCH flag
  spec.files         = Dir.glob(%w[lib/**/* Rakefile], File::FNM_DOTMATCH)
  spec.bindir        = 'bin'
  spec.require_paths = 'lib'
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'http', '~> 4.4.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-ci', '~> 3.4' if ENV['CI']
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'oauth2', '~> 1.4'
  spec.add_development_dependency 'rake'
end
