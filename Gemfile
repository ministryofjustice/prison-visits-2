source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 4.2.3'

gem 'connection_pool'
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
gem 'scenic', '>= 1.2.0'
gem 'govuk_template', '~> 0.17.0'
gem 'govuk_frontend_toolkit', '>= 4.6.1'
gem 'govuk_elements_rails', '>= 1.1.2'
gem 'jquery-rails'
gem 'jquery-ui-rails', '5.0.5'
gem 'jwt'
gem 'draper'

# Fixed version as workaround for Rails version 4.2 expecting method
# 'last_comment' to be defined. Review once we are using a different Rails
# version
gem 'rake'

# Fixed version as workaround for bug in 0.15.5
# https://github.com/getsentry/raven-ruby/issues/460
gem 'sentry-raven'
gem 'sidekiq'
gem 'state_machines-activerecord'
gem 'string_scrubber'
gem 'uglifier'
gem 'uri_template'
gem 'virtus'
gem 'zendesk_api'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'jasmine-jquery-rails'
  gem 'jasmine-rails'
  gem 'parser', '~> 2.3.0.pre.6'
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
