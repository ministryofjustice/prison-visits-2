require 'pvb/instrumentation'

excon_setup_proc = proc do |event|
  event.payload[:category] = :api
end

Rails.application.config.to_prepare do
  PVB::Instrumentation.configure do |config|
    config.logger = Rails.logger
    config.register(
      "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.request",
      PVB::Instrumentation::Excon::Request,
      excon_setup_proc
    )

    config.register(
      "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.retry",
      PVB::Instrumentation::Excon::Retry,
      excon_setup_proc
    )

    config.register(
      "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.response",
      PVB::Instrumentation::Excon::Response,
      excon_setup_proc
    )

    config.register(
      "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.error",
      PVB::Instrumentation::Excon::Error,
      excon_setup_proc
    )

    config.register(
      'faraday.raven', PVB::Instrumentation::Faraday::Request)
  end
end
