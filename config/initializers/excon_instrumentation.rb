require 'pvb/excon/instrument_factory'

ActiveSupport::Notifications.subscribe(/excon/) do |event, start, finish, id, payload|
  instrument = PVB::Excon::InstrumentFactory.for(event, start.to_f, finish.to_f, payload)
  instrument.process
end
