# frozen_string_literal: true

# Same as https://github.com/excon/excon/blob/v0.104.0/lib/excon/middlewares/idempotent.rb
# but without retrying timeouts.
#
# Tests ported over and extended from Excon. Untested parts are 'request_block'
# and 'pipeline' which we don't use.
# :nocov:
module Excon
  module Middleware
    class CustomIdempotent < Excon::Middleware::Base
      def self.valid_parameter_keys
        [
          :idempotent,
          :retries_remaining,
          :retry_errors,
          :retry_interval,
          :retry_limit
        ]
      end

      def request_call(datum)
        datum[:retries_remaining] ||= datum[:retry_limit]
        @stack.request_call(datum)
      end

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
          if datum.key?(:response_block) && datum[:response_block].respond_to?(:rewind)
            datum[:response_block].rewind
          end
          if datum.key?(:pipeline)
            Excon.display_warning('Excon requests can not be :idempotent when pipelining.')
            datum[:idempotent] = false
          end
        end

        if datum[:idempotent] && datum[:retry_errors].any? { |ex|
          datum[:error].is_a?(ex) && !datum[:error].is_a?(Excon::Error::Timeout)
        } && datum[:retries_remaining] > 1

          sleep(datum[:retry_interval]) if datum[:retry_interval]

          # reduces remaining retries, reset connection, and restart request_call
          datum[:retries_remaining] -= 1
          connection = datum.delete(:connection)
          valid_keys = Set.new(connection.valid_request_keys(datum[:middlewares]))
          datum.select! do |key, _| valid_keys.include?(key) end
          connection.request(datum)
        else
          @stack.error_call(datum)
        end
      end
    end
  end
end
