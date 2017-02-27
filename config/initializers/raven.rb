sentry_dsn = ENV['SENTRY_DSN']

if sentry_dsn
  require 'raven'

  Raven.configure do |config|
    config.dsn = sentry_dsn
    config.processors -= [Raven::Processor::PostData]
    config.faraday_builder = proc { |buidler| buidler.request :instrumentation }
  end

  Raven.client.transport.conn.request :instrumentation
else
  # (Rails logger is not initialized yet)
  STDOUT.puts '[WARN] Sentry is not configured (SENTRY_DSN)'
end

ActiveSupport::Notifications.
  subscribe('request.faraday') do |event, start, finish, _id, payload|
  PVB::Instrumentations::InstrumentFactory.for(
    event, start, finish, payload).process
end
