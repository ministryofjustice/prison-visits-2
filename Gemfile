source 'https://rubygems.org'
ruby '2.4.2'

gem 'rails', '~> 5.1'
gem 'active_model_attributes', # Delete when using Rails 5.2
  git: 'https://github.com/alan/active_model_attributes.git',
  ref: 'd690c5fd73bb3fec56a7e906cf014e0b4f41d31f'

gem 'activerecord-safer_migrations'
gem 'base32-crockford', require: 'base32/crockford'
gem 'business'
gem 'did_you_mean'
gem 'draper'
gem 'connection_pool'
gem 'excon'
gem 'highline', require: false
gem 'jbuilder'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'netaddr'
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
gem 'jquery-rails', '~> 4.2.0'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'jwt'
gem 'rake'

gem 'secure_headers'
gem 'sentry-raven'
gem 'sidekiq'
gem 'state_machines-activerecord'
gem 'string_scrubber'

# Newer versions break ie8 js
gem 'uglifier', '~> 2.7.2'
gem 'uri_template'
gem 'zendesk_api'
gem 'pvb-instrumentation',
  git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
  tag: 'v1.0.0'
# gem 'pvb-instrumentation', path: '../pvb-instrumentation'
gem 'email_address_validation',
  git: 'https://github.com/ministryofjustice/email_address_validation',
  ref: 'c19178437958c53fa41fcd54b4ecebe9f8e6a2cf'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine'
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
