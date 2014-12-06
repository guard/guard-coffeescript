# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'guard/coffeescript/version'

Gem::Specification.new do |s|
  s.name        = 'guard-coffeescript'
  s.version     = Guard::CoffeeScriptVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Michael Kessler']
  s.email       = ['michi@flinkfinger.com']
  s.homepage    = 'http://github.com/netzpirat/guard-coffeescript'
  s.summary     = 'Guard gem for CoffeeScript'
  s.description = 'Guard::CoffeeScript automatically generates your JavaScripts from your CoffeeScripts'
  s.license = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'guard-coffeescript'

  s.add_dependency 'guard', '>= 2.1.0'
  s.add_dependency 'guard-compat', '~> 0.3'
  s.add_dependency 'coffee-script', '>= 2.2.0'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rspec', '~> 3.1'

  s.files        = Dir.glob('{lib}/**/*') + %w(LICENSE README.md)
  s.require_path = 'lib'
end
