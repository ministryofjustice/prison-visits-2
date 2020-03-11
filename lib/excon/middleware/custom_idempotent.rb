# frozen_string_literal: true

# Same as https://github.com/excon/excon/blob/v0.55.0/lib/excon/middlewares/idempotent.rb
# but without retrying timeouts.
#
# Tests ported over and extended from Excon. Untested parts are 'request_block'
# and 'pipeline' which we don't use.
# :nocov:
module Excon
  module Middleware
    class CustomIdempotent < Excon::Middleware::Base
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Layout/LineLength
      def error_call(datum)
        if datum[:idempotent]
          if datum.key?(:request_block)
            if datum[:request_block].respond_to?(:rewind)
              datum[:request_block].rewind
            else
              Excon.display_warning('Excon requests with a :request_block must implement #rewind in order to be :idempotent.')
              datum[:idempotent] = false
            end
          end
          if datum.key?(:pipeline)
            Excon.display_warning('Excon requests can not be :idempotent when pipelining.')
            datum[:idempotent] = false
          end
        end

        if datum[:idempotent] && [Excon::Errors::SocketError,
                                  Excon::Error::HTTPStatus].any? { |ex| datum[:error].is_a?(ex) } && datum[:retries_remaining] > 1
          # reduces remaining retries, reset connection, and restart request_call
          datum[:retries_remaining] -= 1
          connection = datum.delete(:connection)
          datum.select! do |key, _| Excon::VALID_REQUEST_KEYS.include?(key) end
          connection.request(datum)
        else
          @stack.error_call(datum)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Layout/LineLength
  end
end
