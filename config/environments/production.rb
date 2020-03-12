Rails.application.configure do
  config.action_mailer.smtp_settings = {
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    address: ENV['SMTP_HOSTNAME'],
    port: ENV['SMTP_PORT'],
    domain: ENV['SMTP_DOMAIN'],
    authentication: :login,
    enable_starttls_auto: true
  }

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false

  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.logger = ActiveSupport::Logger.new(STDOUT)

  config.lograge.custom_options = lambda do |event|
    event.payload[:custom_log_items]
  end

  config.redis_url = ENV['REDIS_URL']

  config.active_job.queue_adapter = :sidekiq

  service_url = if ENV['HEROKU_APP_NAME']
                  URI.parse("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
                else
                  URI.parse(ENV.fetch('STAFF_SERVICE_URL'))
                end

  config.action_controller.default_url_options = { host: service_url.hostname }
  config.action_controller.asset_host = service_url.hostname

  EmailAddressValidation.configure do |config|
    config.mx_checker = MxChecker.new
  end
end
