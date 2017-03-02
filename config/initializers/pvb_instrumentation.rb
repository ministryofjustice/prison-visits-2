PVB::Instrumentation::Registry.register(
  "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.request",
  PVB::Instrumentation::Excon::Request
)

PVB::Instrumentation::Registry.register(
  "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.retry",
  PVB::Instrumentation::Excon::Retry
)

PVB::Instrumentation::Registry.register(
  "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.response",
  PVB::Instrumentation::Excon::Response
)

PVB::Instrumentation::Registry.register(
  "#{Nomis::Client::EXCON_INSTRUMENT_NAME}.error",
  PVB::Instrumentation::Excon::Error
)

PVB::Instrumentation::Registry.register(
  ''
