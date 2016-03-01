Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options =
    { host: 'localhost', protocol: 'http', port: '3000' }
  config.action_mailer.smtp_settings =
    { address: 'localhost', port: 1025, domain: 'localhost' }
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  config.enable_sendgrid_validations = true
  config.mx_checker = MxChecker::Dummy.new

  config.active_job.queue_adapter = :sidekiq

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
end
