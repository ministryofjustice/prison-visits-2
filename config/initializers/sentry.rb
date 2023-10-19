sentry_dsn = Rails.configuration.sentry_dsn

Sentry.init do |config|
  if sentry_dsn
    config.dsn = sentry_dsn
    config.logger = Rails.logger

    # If we're in Heroku, set the environment name to be the current app name
    # This allows us to tell which PR/Review App an error came from
    config.environment = ENV['HEROKU_APP_NAME'] if ENV['HEROKU_APP_NAME'].present?
  else
    # (Rails logger is not initialized yet)
    $stdout.puts '[WARN] Sentry is not configured (SENTRY_DSN)'
  end
end
