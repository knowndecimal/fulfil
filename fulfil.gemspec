# frozen_string_literal: true

require_relative 'lib/fulfil/version'

Gem::Specification.new do |spec|
  spec.name          = 'fulfil-io'
  spec.version       = Fulfil::VERSION
  spec.authors       = ['Chris Moore', 'Kat Fairbanks', 'Stefan Vermaas']
  spec.email         = ['chris@knowndecimal.com']

  spec.summary       = 'Interact with the Fulfil.io API'
  spec.homepage      = 'https://github.com/knowndecimal/fulfil'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # To include hidden files from the lib/ folder you need to use the File::FNM_DOTMATCH flag
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'LICENSE', 'Rakefile', 'README.md']
  end

  spec.bindir        = 'bin'
  spec.require_paths = 'lib'
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']

  spec.add_dependency 'http', '>= 4.4.1', '< 5.2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'dotenv', '~> 2.7', '>= 2.7.6'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-ci', '~> 3.4' if ENV['CI']
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'oauth2', '~> 1.4'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop', '~> 1.36'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.22.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.15'
  spec.add_development_dependency 'webmock'
end
