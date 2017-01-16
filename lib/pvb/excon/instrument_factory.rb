# frozen_string_literal: true
require 'pvb/excon/instrument'

module PVB
  module Excon
    class InstrumentFactory
      REQUEST  = 'nomis_api.request'
      RETRY    = 'nomis_api.retry'
      RESPONSE = 'nomis_api.response'
      ERROR    = 'nomis_api.error'

      class << self
        def for(event, *args)
          instrument_class_for(event).new(*args)
        end

        def instrument_class_for(event)
          case event
          when REQUEST
            Instrument::Request
          when RETRY
            Instrument::Retry
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
