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

  spec.required_ruby_version = '>= 2.7'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # To include hidden files from the lib/ folder you need to use the File::FNM_DOTMATCH flag
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'LICENSE', 'Rakefile', 'README.md']
  end

  spec.bindir        = 'bin'
  spec.require_paths = 'lib'
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']

  spec.add_dependency 'http', '>= 4.4.1', '< 5.3.0'
end
