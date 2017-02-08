Rails.application.configure do
  require 'mailgun_rails'
  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = {
    api_key: ENV.fetch('MAILGUN_API_KEY'),
    domain: ENV.fetch('MAILGUN_DOMAIN')
  }

  service_url = URI.parse(ENV.fetch('STAFF_SERVICE_URL'))
  config.action_mailer.default_url_options = {
    protocol: service_url.scheme,
    host: service_url.hostname,
    port: service_url.port
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

  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.logger = ActiveSupport::Logger.new \
    "#{Rails.root}/log/logstash_#{Rails.env}.json"

  config.mx_checker = MxChecker.new

  config.active_job.queue_adapter = :sidekiq
end
