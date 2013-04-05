# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hpfeeds/version'

Gem::Specification.new do |spec|
  spec.name          = "hpfeeds"
  spec.version       = HPFeeds::VERSION
  spec.authors       = ["Francesco Coda Zabetta"]
  spec.email         = ["francesco.codazabetta@gmail.com"]
  spec.description   = %q{Ruby client for HPFeeds protocol}
  spec.summary       = %q{Ruby client for HPFeeds protocol}
  spec.homepage      = "https://github.com/vicvega/hpfeeds-ruby"
  spec.license       = "MIT"

  spec.files = Dir["{config,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md", 'CHANGELOG.md']
  spec.test_files = Dir["test/**/*"]

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
