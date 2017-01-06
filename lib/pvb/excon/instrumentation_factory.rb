require 'pvb/excon/instrumentation/instrument'

module PVB
  module Excon
    class InstrumentationFactory
      class << self

        def for(event, *args)
          instrument_class_for(event).new(*args)
        end

        def instrument_class_for(event)
          case event
          when 'excon.request'
            Instrumentation::Request
          when 'excon.response'
            Instrumentation::Response
          end
        end
      end
    end
  end
end
