require 'pvb/excon/instrument'

module PVB
  module Excon
    class InstrumentFactory
      REQUEST  = 'excon.request'.freeze
      RETRY    = 'excon.retry'.freeze
      RESPONSE = 'excon.response'.freeze
      ERROR    = 'excon.error'.freeze

      class << self
        def for(event, *args)
          instrument_class_for(event).new(*args)
        end

        def instrument_class_for(event)
          case event
          when REQUEST, RETRY
            Instrument::Request
          when RESPONSE
            Instrument::Response
          when ERROR
            Instrument::Error
          end
        end
      end
    end
  end
end
