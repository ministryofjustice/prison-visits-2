Rails.application.configure do
  config.hosts << ENV['STAFF_SERVICE_URL'].gsub('https://', '') if ENV['STAFF_SERVICE_URL']
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # check we use mailtrap
  # usefull for testing email and integration tests
  # which run in developement mode in wercker CI
  if ENV['SMTP_DOMAIN'] == 'smtp.mailtrap.io'
    config.email_setttings = {
      domain: ENV.fetch('SMTP_DOMAIN'),
    }
  else
    config.email_setttings = { domain: 'localhost' }
  end

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true

  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  config.active_job.queue_adapter = :sidekiq

  config.assets.precompile += %w[jasmine-jquery.js]

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

  EmailAddressValidation.configure do |config|
    config.mx_checker = MxChecker::Dummy.new
  end
end
