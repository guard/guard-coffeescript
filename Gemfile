source 'https://rubygems.org'

gemspec

gem 'rake'

# The JS runtime is needed because ExecJS searches one when the module is loaded.
# This breaks travis builds even when the compiler is stubbed.
platform :jruby do
  gem 'therubyrhino'
end

unless ENV['TRAVIS']
  gem 'redcarpet'
  gem 'yard'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
  gem 'json'
end

group :development do
  gem 'rubocop', github: 'bbatsov/rubocop', branch: 'master', require: false
end
