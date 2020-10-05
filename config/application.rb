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
    config.eager_load_paths += %w[ app/services/nomis ]

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

    config.connection_pool_size =
      config.database_configuration[Rails.env]['pool'] || 5

    config.pvb_team_email = ENV['PVB_TEAM_EMAIL']

    # If you want to record new/re-record VCR cassettes then you need to update the line
    # below to 'config.call', once completed you can return it to the value below so that
    # the VCR cassettes will be used during testing
    feature_flag_value = proc do |&config|
      Rails.env.test? ? nil : config.call
    end

    config.nomis_staff_slot_availability_enabled = feature_flag_value.call {
      ENV['NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED']&.downcase == 'true'
    }

    config.staff_prisons_with_slot_availability = feature_flag_value.call {
      ENV['STAFF_PRISONS_WITH_SLOT_AVAILABILITY']&.split(',')&.map(&:strip) || []
    }

    config.public_prisons_with_slot_availability = feature_flag_value.call {
      ENV['PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY']&.split(',')&.map(&:strip) || []
    }

    config.zendesk_token = feature_flag_value.call {
      ENV.fetch('ZENDESK_TOKEN', nil)
    }

    config.zendesk_url = feature_flag_value.call {
      ENV.fetch('ZENDESK_URL', nil)
    }

    config.zendesk_username = feature_flag_value.call {
      ENV.fetch('ZENDESK_USERNAME', nil)
    }

    # Details for authenticating API calls via the HMPPS SSO
    config.nomis_oauth_host = ENV['NOMIS_OAUTH_HOST']&.strip
    config.nomis_oauth_client_id = ENV['NOMIS_OAUTH_CLIENT_ID']&.strip
    config.nomis_oauth_client_secret = ENV['NOMIS_OAUTH_CLIENT_SECRET']&.strip
    config.nomis_oauth_public_key = ENV['NOMIS_OAUTH_PUBLIC_KEY']&.strip
    config.prison_api_host = ENV['PRISON_API_HOST']&.strip
  end
end
