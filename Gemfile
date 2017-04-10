source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 4.2.3'

gem 'connection_pool'
gem 'base32-crockford', require: 'base32/crockford'
gem 'excon'
gem 'highline', require: false
gem 'jbuilder'
gem 'kramdown'
gem 'lograge'
gem 'logstash-event'
gem 'netaddr'
# Pinned to 1.3.1 due to https://github.com/intridea/omniauth-oauth2/issues/81
gem 'omniauth-oauth2', '1.3.1'
gem 'pg'
gem 'phonelib'
gem 'premailer-rails'
gem 'puma'
gem 'redcarpet'
gem 'request_store'
gem 'sass-rails'
gem 'scenic'
gem 'govuk_template', '~> 0.17.0'
gem 'govuk_frontend_toolkit', '~> 4.6.1'
gem 'govuk_elements_rails', '~> 1.1.2'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'jwt'
gem 'draper'
gem 'rake'

gem 'sentry-raven', '~> 2.4.0'

gem 'sidekiq'
gem 'state_machines-activerecord'
gem 'string_scrubber'

# Newer versions break ie8 js
gem 'uglifier', '~> 2.7.2'
gem 'uri_template'
gem 'virtus'
gem 'zendesk_api'
gem 'pvb-instrumentation',
  git: 'https://github.com/ministryofjustice/pvb-instrumentation.git',
  ref: '639bd30e211846a0d76c1d869b376fa2b4c30568'
# gem 'pvb-instrumentation', path: '../pvb-instrumentation'

gem 'secure_headers'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine-rails'
  gem 'parser'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.0'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'awesome_print', require: 'ap'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'fuubar'
  gem 'launchy'
  gem 'poltergeist'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
  gem 'shoulda-matchers'
end
