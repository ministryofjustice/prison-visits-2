source 'https://rubygems.org'

gem 'rails', '~> 5.2.8.1'
# This needs to be in here for Heroku
ruby '2.6.7'

gem 'activerecord-safer_migrations'
gem 'base32-crockford', require: 'base32/crockford'
gem 'business', '1.18.0'
gem 'connection_pool'
gem 'draper'
gem 'excon', '0.62.0' # There is an issue with subsequent versions where there is a
# regression, which isn't fixed in any future versions. An agreement has been reached
# within the team to pin Excon to the current version, with the plan to
# replace it with another HTTP client, probably Faraday.
gem 'govuk_elements_rails'
gem 'govuk_frontend_toolkit', '8.2.0'
gem 'govuk_template'
gem 'jaro_winkler'
gem 'jbuilder'
gem 'jquery-rails', '~> 4.4.0'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'jwt'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'netaddr', '~> 1.5.1'
gem 'notifications-ruby-client', '~> 5.3'
gem 'omniauth-oauth2'
gem 'pg'
gem 'phonelib'
gem 'premailer-rails'
gem 'prometheus_exporter'
gem 'puma', '5.6.7'
gem 'rack', '>= 2.1.4'
gem 'rake'
gem 'request_store'
gem 'sassc-rails'
gem 'scenic'
gem 'sentry-rails'
gem 'sidekiq'
gem 'sprockets', '< 4'
gem 'state_machines-activerecord'
gem 'string_scrubber'
gem 'turnout'
gem 'rack-canonical-host'

# Newer versions break ie8 js
gem 'uglifier', '~> 2.7.2'
gem 'uri_template'
gem 'zendesk_api'
gem 'pvb-instrumentation',
    git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
    tag: 'v1.0.1'
# gem 'pvb-instrumentation', path: '../pvb-instrumentation'
gem 'email_address_validation',
    git: 'https://github.com/ministryofjustice/email_address_validation',
    ref: 'd37caea140a11bbb82f6abfbecef39fef78b97e8'

group :developmemt do
  gem 'guard-rspec'
  gem 'guard-rubocop', '1.4.0'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman', '>= 5.0.4'
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'jasmine-jquery-rails'
  gem 'jasmine', '3.9.2'
  gem 'parser'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop-govuk', '3.3.2'
  gem 'rubocop', '0.80.1'
  gem 'rubocop-performance', '1.6.1'
  gem 'rubocop-rails', '2.5.2'
  gem 'rubocop-rspec', '1.41.0'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cuprite'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
