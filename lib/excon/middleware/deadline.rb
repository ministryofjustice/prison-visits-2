# frozen_string_literal: true

module Excon
  module Errors
    class DeadlineError < Error
      def initialize(deadline, exceeded_by)
        @deadline = deadline
        @exceeded_by = exceeded_by
      end

      def message
        "Deadline exceeded by #{@exceeded_by.abs}, \
expected to have completed by #{@deadline.to_fs(:iso8601)}"
      end
    end
  end

  module Middleware
    class Deadline < Excon::Middleware::Base
      def request_call(datum)
        if datum[:deadline]
          time_left = datum[:deadline] - Time.zone.now
          unless time_left > 0
            fail Errors::DeadlineError.new(datum[:deadline], time_left)
          end

          datum[:read_timeout] = time_left
          datum[:write_timeout] = time_left
        end

        @stack.request_call(datum)
      end
    end
  end
end
