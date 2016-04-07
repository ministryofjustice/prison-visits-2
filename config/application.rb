require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

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

    config.action_dispatch.rescue_responses.merge!(
      'StateMachines::InvalidTransition' => :unprocessable_entity
    )

    config.ga_id = ENV['GA_TRACKING_ID']

    config.smoke_test =
      OpenStruct.new(
        local_part:
          Regexp.escape(
            ENV.fetch('SMOKE_TEST_EMAIL_LOCAL_PART', 'prison-visits-smoke-test')
          ),
        domain:
          Regexp.escape(
            ENV.fetch('SMOKE_TEST_EMAIL_DOMAIN', 'digital.justice.gov.uk')
          )
      )

    config.exceptions_app = routes

    if ENV['ASSET_HOST']
      config.asset_host = ENV['ASSET_HOST']
    end

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      event.payload[:custom_log_items]
    end

    # Filter skyscape proxy IPs while computing the client's real IP address.
    # Note: This can be removed after PVB1 redirction has been removed.
    skyscape_proxy_ips = ['185.40.9.51', '185.40.9.60']
    trusted_proxies =
      ActionDispatch::RemoteIp::TRUSTED_PROXIES + skyscape_proxy_ips
    config.middleware.swap ActionDispatch::RemoteIp,
      ActionDispatch::RemoteIp, true, trusted_proxies

    config.sendgrid_api_user = ENV['SMTP_USERNAME']
    config.sendgrid_api_key = ENV['SMTP_PASSWORD']

    config.disable_sendgrid_validations =
      !ENV.key?('ENABLE_SENDGRID_VALIDATIONS') &&
      !ENV.key?('SMTP_USERNAME') &&
      !ENV.key?('SMTP_PASSWORD')

    config.nomis_api_host = ENV.fetch('NOMIS_API_HOST', nil)
    config.staff_info_endpoint = ENV.fetch('STAFF_INFO_ENDPOINT', nil)
  end
end
