module PVB
  class ExceptionHandler
    def self.capture_exception(exception, options = {})
      raise exception unless Rails.configuration.sentry_dsn

      Sentry.capture_exception(exception, **options)
    end
  end
end
