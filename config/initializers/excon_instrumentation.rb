require 'pvb/excon/instrument_factory'

ActiveSupport::Notifications.subscribe(/excon/) do |event, start, finish, _id, payload|
  # Excon uses ActiveSupport if available and triggers several type of events depending
  # on each phase of the request: excon.request, excon.retry, excon.response, excon.error
  instrument = PVB::Excon::InstrumentFactory.for(event, start.to_f, finish.to_f, payload)
  instrument.process
end
