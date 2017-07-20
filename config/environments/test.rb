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
  config.active_support.test_order = :random
  config.active_support.deprecation = :stderr

  config.mx_checker = MxChecker::Dummy.new

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

  # Always make testing calls to the NOMIS dev server, and hard-code
  # credentials to avoid the possibility of leaking sensitive credentials or
  # returned data into VCR test output files.
  config.nomis_api_host = 'http://151.237.239.116:4888'
  config.nomis_api_token = nil
  config.nomis_api_key = nil

  # Set feature flags to nil to prevent them being set by local .env
  # and to ensure tests pass wherever they are run from.
  config.nomis_staff_prisoner_check_enabled = nil
  config.nomis_public_prisoner_check_enabled = nil
  config.nomis_staff_prisoner_availability_enabled = nil
  config.nomis_public_prisoner_availability_enabled = nil
  config.nomis_staff_slot_availability_enabled = nil
  config.staff_prisons_with_slot_availability = nil
  config.public_prisons_with_slot_availability = nil
  config.staff_prisons_with_nomis_contact_list = nil
  config.nomis_staff_book_to_nomis_enabled = nil
  config.staff_prisons_with_book_to_nomis = nil
end
