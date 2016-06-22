# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'digital/transport/version'

Gem::Specification.new do |spec|
  spec.name = 'digital-transport'
  spec.version = Digital::Transport::VERSION
  spec.authors = ['Roman Lishtaba']
  spec.email = ['roman@lishtaba.com']

  spec.summary = 'interface between multiple transport adapters'
  spec.description = 'Library intended to unify interface between multiple transport adapters'
  spec.homepage = 'https://github.com/rlishtaba/ruby-digital-transport'
  spec.license = 'MIT'
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'cucumber', '=1.3.20'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'simplecov', '=0.9.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rspec', '~> 3.4'

  spec.add_dependency 'functional-ruby'
  spec.add_dependency 'rs_232', '~>3.0.0.pre2' unless RUBY_PLATFORM === /java/
end
