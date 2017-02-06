module PVB
  module Excon
    module Instrument
      class Error
        include Instrument

        def process
          Instrumentation.append_to_log(api_call_error => true)
          Instrumentation.incr(:api_error_count)
        end
      end
    end
  end
end
