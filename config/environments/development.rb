require 'uglifier'

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # check we use mailtrap
  # usefull for testing email and integration tests
  # which run in developement mode in wercker CI
  if ENV['SMTP_DOMAIN'] == 'smtp.mailtrap.io'
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: ENV.fetch('SMTP_USERNAME'),
      password: ENV.fetch('SMTP_PASSWORD'),
      address: ENV.fetch('SMTP_HOSTNAME'),
      port: ENV.fetch('SMTP_PORT'),
      domain: ENV.fetch('SMTP_DOMAIN'),
      authentication: :cram_md5
    }
  else
    config.action_mailer.raise_delivery_errors = false
    config.action_mailer.smtp_settings =
      { address: 'localhost', port: 1025, domain: 'localhost' }
  end

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true

  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  config.active_job.queue_adapter = :sidekiq

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

  EmailAddressValidation.configure do |config|
    config.mx_checker = MxChecker::Dummy.new
  end
end
