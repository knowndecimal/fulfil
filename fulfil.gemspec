# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fulfil/version'

Gem::Specification.new do |spec|
  spec.name          = 'fulfil-io'
  spec.version       = Fulfil::VERSION
  spec.authors       = ['Chris Moore', 'Kat Fairbanks']
  spec.email         = ['chris@knowndecimal.com']

  spec.summary       = 'Interact with the Fulfil.io API'
  spec.homepage      = 'https://github.com/knowndecimal/fulfil'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-ci', '~> 3.4' if ENV['CI']
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'oauth2', '~> 1.4'
  spec.add_development_dependency 'rake'
end
