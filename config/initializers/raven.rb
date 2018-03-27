sentry_dsn = Rails.configuration.sentry_dsn

if sentry_dsn

  Raven.configure do |config|
    config.dsn = sentry_dsn
    config.processors -= [Raven::Processor::PostData]
    config.faraday_builder = proc { |builder|
      builder.request :instrumentation, name: 'faraday.raven'
    }
  end
else
  # (Rails logger is not initialized yet)
  STDOUT.puts '[WARN] Sentry is not configured (SENTRY_DSN)'
end
