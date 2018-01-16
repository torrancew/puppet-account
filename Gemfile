source 'https://rubygems.org'

PUPPET_VERSION = ENV['PUPPET_VERSION'] || '~> 4.10'

gem 'puppet', PUPPET_VERSION

gem 'puppet-lint'
gem 'semantic_puppet'
gem 'metadata-json-lint'
gem 'puppetlabs_spec_helper'

group :test do
  gem 'rspec-puppet'
end

group :acceptance do
  gem 'beaker-rspec'
end

group :doc do
  gem 'puppet-strings'
end
