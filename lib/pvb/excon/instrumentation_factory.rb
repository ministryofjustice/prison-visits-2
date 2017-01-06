require 'pvb/excon/instrumentation/instrument'

module PVB
  module Excon
    class InstrumentationFactory

      REQUEST  = 'excon.request'.freeze
      RESPONSE = 'excon.response'.freeze
      ERROR    = 'excon.error'.freeze

      class << self

        def for(event, *args)
          instrument_class_for(event).new(*args)
        end

        def instrument_class_for(event)
          case event
          when REQUEST
            Instrumentation::Request
          when RESPONSE
            Instrumentation::Response
          when ERROR
            Instrumentation::Error
          end
        end
      end
    end
  end
end
