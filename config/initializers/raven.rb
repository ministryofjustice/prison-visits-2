sentry_dsn = ENV['SENTRY_DSN']

if sentry_dsn
  require 'raven'

  Raven.configure do |config|
    config.dsn = sentry_dsn
  end
else
  # rubocop:disable Rails/Output
  # (Rails logger is not initialized yet)
  puts '[WARN] Sentry is not configured (SENTRY_DSN)'
end
