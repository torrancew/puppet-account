require 'rubygems'
require 'puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'

# Disable unwanted checks
['80chars', 'autoloader_layout', 'quoted_booleans'].each do |chk|
  PuppetLint.configuration.send('disable_%s' % [chk])
end

PuppetLint.configuration.ignore_paths = ['vendor/**/*.pp']

