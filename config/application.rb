require File.expand_path('boot', __dir__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require_relative '../app/middleware/http_method_not_allowed'

Bundler.require(*Rails.groups)

module PrisonVisits
  class Application < Rails::Application
    config.phase = 'live'
    config.product_type = 'service'

    config.autoload_paths += %w[ app/mailers/concerns ]

    config.i18n.load_path =
      Dir[Rails.root.join('config', 'locales', '{en,cy}', '*.yml').to_s]
    config.i18n.default_locale = :en

    config.time_zone = 'London'

    config.
      action_dispatch.
      rescue_responses['StateMachines::InvalidTransition'] = :unprocessable_entity

    config.ga_id = ENV['GA_TRACKING_ID']

    config.exceptions_app = ->(env) { ErrorHandler.call(env) }

    if ENV['ASSET_HOST']
      config.asset_host = ENV['ASSET_HOST']
    end

    config.remove_load_test_data = ENV['REMOVE_LOAD_TEST_DATA']

    config.sentry_dsn = ENV['SENTRY_DSN']
    config.sentry_js_dsn = ENV['SENTRY_JS_DSN']

    config.middleware.insert_before Rack::Head, HttpMethodNotAllowed

    config.sendgrid_api_user = ENV['SMTP_USERNAME']
    config.sendgrid_api_key = ENV['SMTP_PASSWORD']

    config.disable_sendgrid_validations =
      !ENV.key?('ENABLE_SENDGRID_VALIDATIONS') &&
      !ENV.key?('SMTP_USERNAME') &&
      !ENV.key?('SMTP_PASSWORD')

    read_key = lambda { |string|
      begin
        der = Base64.decode64(string)
        OpenSSL::PKey::EC.new(der)
      rescue OpenSSL::PKey::ECError => e
        STDOUT.puts "[WARN] Invalid ECDSA key: #{e}"
        nil
      rescue ArgumentError => e
        STDOUT.puts "[WARN] Invalid ECDSA key: #{e}"
        nil
      end
    }

    config.staff_info_endpoint = ENV.fetch('STAFF_INFO_ENDPOINT', nil)

    config.connection_pool_size =
      config.database_configuration[Rails.env]['pool'] || 5

    config.pvb_team_email = ENV['PVB_TEAM_EMAIL']

    feature_flag_value = proc do |&config|
      Rails.env.test? ? nil : config.call
    end

    config.nomis_api_host = feature_flag_value.call do
      ENV.fetch('NOMIS_API_HOST', nil)
    end

    config.nomis_api_token = feature_flag_value.call do
      ENV.fetch('NOMIS_API_TOKEN', nil)
    end

    config.nomis_api_key = feature_flag_value.call do
      read_key.call(ENV.fetch('NOMIS_API_KEY', ''))
    end

    config.nomis_staff_slot_availability_enabled = feature_flag_value.call do
      ENV['NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED']&.downcase == 'true'
    end

    config.staff_prisons_with_slot_availability = feature_flag_value.call do
      ENV['STAFF_PRISONS_WITH_SLOT_AVAILABILITY']&.split(',')&.map(&:strip) || []
    end

    config.public_prisons_with_slot_availability = feature_flag_value.call do
      ENV['PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY']&.split(',')&.map(&:strip) || []
    end

    config.nomis_staff_offender_restrictions_enabled = feature_flag_value.call do
      ENV['NOMIS_STAFF_OFFENDER_RESTRICTIONS_ENABLED']&.downcase == 'true'
    end

    config.nomis_staff_book_to_nomis_enabled = feature_flag_value.call do
      ENV['NOMIS_STAFF_BOOK_TO_NOMIS_ENABLED']&.downcase == 'true'
    end

    config.staff_prisons_with_book_to_nomis = feature_flag_value.call do
      ENV['STAFF_PRISONS_WITH_BOOK_TO_NOMIS']&.split(',')&.map(&:strip) || []
    end

    config.staff_prisons_with_prisoner_restrictions_info = feature_flag_value.call do
      ENV['STAFF_PRISONS_WITH_PRISONER_RESTRICTIONS_INFO']&.split(',')&.map(&:strip) || []
    end

    config.zendesk_token = feature_flag_value.call do
      ENV.fetch('ZENDESK_TOKEN', nil)
    end

    config.zendesk_url = feature_flag_value.call do
      ENV.fetch('ZENDESK_URL', nil)
    end

    config.zendesk_user = feature_flag_value.call do
      ENV.fetch('ZENDESK_USER', nil)
    end
  end
end
