# frozen_string_literal: true

# Same as https://github.com/excon/excon/blob/v0.104.0/lib/excon/middlewares/instrumentor.rb
# but with a few changes documented below
#
# :nocov:
module Excon
  module Middleware
    class CustomInstrumentor < Excon::Middleware::Base
      def self.valid_parameter_keys
        [
          :logger,
          :instrumentor,
          :instrumentor_name
        ]
      end

      def error_call(datum)
        if datum.key?(:instrumentor)
          datum[:instrumentor].instrument("#{datum[:instrumentor_name]}.error", error: datum[:error]) do
            @stack.error_call(datum)
          end
        else
          @stack.error_call(datum)
        end
      end

      def request_call(datum)
        # Set the retries_remaining if not set
        # The CustomInstrumentor is first in the middleware stack while the key is set in the CustomIdempotent
        # https://github.com/ministryofjustice/prison-visits-2/blob/main/app/services/nomis/client.rb#L111
        datum[:retries_remaining] ||= datum[:retry_limit]

        if datum.key?(:instrumentor)
          if datum[:retries_remaining] < datum[:retry_limit]
            event_name = "#{datum[:instrumentor_name]}.retry"
          else
            event_name = "#{datum[:instrumentor_name]}.request"
          end
          datum[:instrumentor].instrument(event_name, datum) do
            @stack.request_call(datum)
          end
        else
          @stack.request_call(datum)
        end
      end

      # Changed from `datum[:response]` to `datum` since the response is not
      # available when calling the instrumentation.
      def response_call(datum)
        if datum.key?(:instrumentor)
          datum[:instrumentor].instrument("#{datum[:instrumentor_name]}.response", datum) do
            @stack.response_call(datum)
          end
        else
          @stack.response_call(datum)
        end
      end
    end
  end
end
