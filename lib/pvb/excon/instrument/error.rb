# frozen_string_literal: true
module PVB
  module Excon
    module Instrument
      class Error
        include Instrument

        def process
          Instrumentation.incr(:api_error_count)
        end
      end
    end
  end
end
