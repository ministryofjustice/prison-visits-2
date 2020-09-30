ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

require 'capybara/rspec'
require 'ffaker'
require 'webmock/rspec'
require 'support/helpers/controller_helper'

WebMock.disable_net_connect!(allow: 'codeclimate.com', allow_localhost: true)

Capybara.javascript_driver = :selenium
Capybara.default_max_wait_time = 4
Capybara.asset_host = 'http://localhost:3000'

ActiveRecord::Migration.maintain_test_schema!

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include StaffResponseHelper
  config.include ControllerHelper, type: :controller
  config.include ConfigurationHelpers
  config.include ServiceHelpers
  config.include JWTHelper
  config.include AuthHelper

  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, except: %w(public.ar_internal_metadata))
  end

  config.around(:each, :vcr) do |example|
    WebMock.enable_net_connect!
    example.run
    WebMock.disable_net_connect!(allow: 'codeclimate.com', allow_localhost: true)
  end

  config.before(:each) do
    I18n.locale = I18n.default_locale
    RequestStore.clear!
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each, type: :controller) do |ex|
    EstateSSOMapper.reset_grouped_estates
    ex.run
    EstateSSOMapper.reset_grouped_estates
  end

  config.around(:each, type: :feature) do |ex|
    EstateSSOMapper.reset_grouped_estates
    ex.run
    EstateSSOMapper.reset_grouped_estates
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :expect_exception) do
    Rails.configuration.sentry_dsn = 'https://test.com'
    allow(Raven).to receive(:capture_exception)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each, :expect_exception) do
    Rails.configuration.sentry_dsn = nil
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
