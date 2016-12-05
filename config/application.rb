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
  end
end
