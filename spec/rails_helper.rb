ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

require 'capybara/rspec'
require 'capybara/poltergeist'
require 'ffaker'
require 'webmock/rspec'
require 'support/helpers/controller_helper'

WebMock.disable_net_connect!(allow: 'codeclimate.com', allow_localhost: true)

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 3
Capybara.asset_host = 'http://localhost:3000'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.include FactoryGirl::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ControllerHelper, type: :controller

  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:suite, js: true) do
    OmniAuth.config.test_mode = true
  end

  config.before(:each) do
    I18n.locale = I18n.default_locale
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
