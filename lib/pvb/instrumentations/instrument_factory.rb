require 'pvb/instrumentations/instrument'

module PVB
  module Instrumentations
    class InstrumentFactory
      REQUEST         = 'nomis_api.request'.freeze
      RETRY           = 'nomis_api.retry'.freeze
      RESPONSE        = 'nomis_api.response'.freeze
      ERROR           = 'nomis_api.error'.freeze
      FARADAY_REQUEST = 'request.faraday'.freeze

      class << self
        def for(event, *args)
          instrument_class_for(event).new(*args)
        end

        # rubocop:disable Metrics/MethodLength
        def instrument_class_for(event)
          case event
          when REQUEST
            Excon::Request
          when RETRY
            Excon::Retry
          when RESPONSE
            Excon::Response
          when ERROR
            Excon::Error
          when FARADAY_REQUEST
            Faraday::Request
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
