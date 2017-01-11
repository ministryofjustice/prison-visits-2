# frozen_string_literal: true
Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.smtp_settings =
    { address: 'localhost', port: 1025, domain: 'localhost' }
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  config.mx_checker = MxChecker::Dummy.new

  config.active_job.queue_adapter = :sidekiq

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

  config.nomis_api_host = ENV.fetch('NOMIS_API_HOST',
    'http://172.22.16.2:8080/')
end
