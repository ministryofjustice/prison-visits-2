Rails.application.configure do
  config.action_mailer.smtp_settings = { domain: 'email.test.host' }
  config.cache_classes = true
  config.eager_load = false
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_dispatch.show_exceptions = false
  config.active_job.queue_adapter = :test
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options =
    { host: 'localhost', protocol: 'https', port: '3000' }
  config.active_support.test_order = :random
  config.active_support.deprecation = :stderr

  config.enable_sendgrid_validations = true
  config.mx_checker = MxChecker::Dummy.new

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
end
