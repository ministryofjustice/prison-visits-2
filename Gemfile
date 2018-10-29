source 'https://rubygems.org'
ruby '2.5.3'

gem 'rails', '~> 5.2'

gem 'activerecord-safer_migrations'
gem 'base32-crockford', require: 'base32/crockford'
gem 'business'
gem 'draper'
gem 'connection_pool'
gem 'did_you_mean'
gem 'excon'
gem 'jbuilder'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'netaddr', '~> 1.5.1'
gem 'omniauth-oauth2'
gem 'pg'
gem 'phonelib'
gem 'premailer-rails'
gem 'puma'
gem 'request_store'
gem 'sass-rails'
gem 'scenic'
gem 'govuk_template'
gem 'govuk_frontend_toolkit'
gem 'govuk_elements_rails'
gem 'jquery-rails', '~> 4.3.3'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'jwt'
gem 'rake'

gem 'sentry-raven', require: 'raven'
gem 'sidekiq'
gem 'state_machines-activerecord'
gem 'string_scrubber'

# Newer versions break ie8 js
gem 'uglifier', '~> 4.1.19'
gem 'uri_template'
gem 'zendesk_api'
gem 'pvb-instrumentation',
  git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
  tag: 'v1.0.1'
# gem 'pvb-instrumentation', path: '../pvb-instrumentation'
gem 'email_address_validation',
  git: 'https://github.com/ministryofjustice/email_address_validation',
  ref: '5ed2fb93f8d5bc419f03cecb408c688c5bd9fd74'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine', '~> 3.3'
  gem 'parser'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'awesome_print', require: 'ap'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'launchy'
  gem 'rspec-collection_matchers'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end
