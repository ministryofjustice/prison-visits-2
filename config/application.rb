require File.expand_path('../boot', __FILE__)

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

    config.active_record.raise_in_transactional_callbacks = true

    # The last 3 errors can be removed with Rails 5. See Rails PR #19632
    config.action_dispatch.rescue_responses.merge!(
      'StateMachines::InvalidTransition' => :unprocessable_entity,
      'ActionController::ParameterMissing' => :bad_request,
      'Rack::Utils::ParameterTypeError' => :bad_request,
      'Rack::Utils::InvalidParameterError' => :bad_request
    )

    config.ga_id = ENV['GA_TRACKING_ID']

    config.exceptions_app = ->(env) { ErrorHandler.call(env) }

    if ENV['ASSET_HOST']
      config.asset_host = ENV['ASSET_HOST']
    end

    config.sentry_dsn = ENV['SENTRY_DSN']
    config.sentry_js_dsn = ENV['SENTRY_JS_DSN']

    config.lograge.enabled = Rails.env.production?
    config.lograge.custom_options = lambda do |event|
      event.payload[:custom_log_items]
    end

    config.middleware.insert_before ActionDispatch::ParamsParser,
      HttpMethodNotAllowed

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

    unless Rails.env.test?
      config.nomis_api_host = ENV.fetch('NOMIS_API_HOST', nil)
      config.nomis_api_token = ENV.fetch('NOMIS_API_TOKEN', nil)
      config.nomis_api_key = read_key.call(ENV.fetch('NOMIS_API_KEY', ''))
    end

    config.staff_info_endpoint = ENV.fetch('STAFF_INFO_ENDPOINT', nil)

    config.connection_pool_size =
      config.database_configuration[Rails.env]['pool'] || 5

    config.nomis_staff_prisoner_check_enabled =
      ENV['NOMIS_STAFF_PRISONER_CHECK_ENABLED'].try(:downcase) == 'true'

    config.nomis_public_prisoner_check_enabled =
      ENV['NOMIS_PUBLIC_PRISONER_CHECK_ENABLED'].try(:downcase) == 'true'

    # Prisoner availability depends on the prisoner check flag because to check
    # the availability we need to call the api used in the prisoner check to get
    # the offender id.
    config.nomis_staff_prisoner_availability_enabled =
      config.nomis_staff_prisoner_check_enabled &&
      ENV['NOMIS_STAFF_PRISONER_AVAILABILITY_ENABLED'].try(:downcase) == 'true'

    config.nomis_public_prisoner_availability_enabled =
      config.nomis_public_prisoner_check_enabled &&
      ENV['NOMIS_PUBLIC_PRISONER_AVAILABILITY_ENABLED'].try(:downcase) == 'true'

    config.nomis_staff_slot_availability_enabled =
      ENV['NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED'].try(:downcase) == 'true'

    config.staff_prisons_with_slot_availability =
      ENV['STAFF_PRISONS_WITH_SLOT_AVAILABILITY']&.split(',')&.map(&:strip) || []

    config.public_prisons_with_slot_availability =
      ENV['PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY']&.split(',')&.map(&:strip) || []

    config.staff_prisons_with_nomis_contact_list =
      ENV['STAFF_PRISONS_WITH_NOMIS_CONTACT_LIST']&.split(',')&.map(&:strip) || []
  end
end
