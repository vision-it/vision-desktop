source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['6.17.0']
gem 'puppet', puppetversion

gem 'puppetlabs_spec_helper', '2.15.0'
gem 'rake', '13.0.1'
gem 'rspec-puppet', '2.7.10'

group :rubocop do
  gem 'rubocop', '0.89.1'
  gem 'rubocop-rspec', '1.42.0'
end

group :testing do
  gem 'metadata-json-lint', '1.2.2'
  gem 'rspec-puppet-facts', '2.0.0'
end

group :acceptance do
  gem 'serverspec'
  gem 'beaker-docker'
  gem 'beaker-puppet'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-rspec'
  gem 'rbnacl', '>= 4'
  gem 'rbnacl-libsodium'
  gem 'bcrypt_pbkdf'
  gem 'ed25519'
end

group :development do
  gem 'travis',      :require => false
  gem 'travis-lint', :require => false
end
