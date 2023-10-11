ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'ffaker'
require 'webmock/rspec'
require 'support/helpers/controller_helper'

Dir[Rails.root.join('spec/support/features/*')].sort.each { |f| require f }

WebMock.disable_net_connect!(allow: 'codeclimate.com', allow_localhost: true)

Capybara.default_max_wait_time = 4
Capybara.asset_host = 'http://localhost:3000'
Capybara.server = :puma, { Silent: true }
Capybara.default_normalize_ws = true
Capybara.save_path = ENV.fetch("CAPYBARA_ARTIFACTS", "./tmp/capybara")

ActiveRecord::Migration.maintain_test_schema!

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include StaffResponseHelper
  config.include ControllerHelper, type: :controller
  config.include ConfigurationHelpers
  config.include AuthHelper
  config.include ServiceHelpers
  config.include JWTHelper
  config.include AuthHelper
  config.include FeaturesHelper

  config.infer_spec_type_from_file_location!

  config.before(:each) do
    I18n.locale = I18n.default_locale
    RequestStore.clear!
  end

  config.before(:each, :expect_exception) do
    Rails.configuration.sentry_dsn = 'https://test.com'
    allow(Sentry).to receive(:capture_exception)
  end

  config.after(:each, :expect_exception) do
    Rails.configuration.sentry_dsn = nil
  end

  # in VCR mode, allow HTTP connections to T3, but then
  # reset back to default afterwards
  config.around(:each, :vcr) do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!(allow: 'codeclimate.com', allow_localhost: true)
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
