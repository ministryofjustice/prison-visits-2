module PVB
  class ExceptionHandler
    def self.capture_exception(exception, options = nil)
      raise exception unless Rails.configuration.sentry_dsn

      args = [exception, options].compact
      Sentry.capture_exception(*args)
    end
  end
end
