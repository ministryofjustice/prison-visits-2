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
Capybara.wait_on_first_by_default = true
Capybara.asset_host = 'http://localhost:3000'

ActiveRecord::Migration.maintain_test_schema!

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include StaffResponseHelper
  config.include ControllerHelper, type: :controller
  config.include ConfigurationHelpers
  config.include ServiceHelpers

  config.infer_spec_type_from_file_location!

  config.before(:each) do
    I18n.locale = I18n.default_locale
    RequestStore.clear!
  end

end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
