module PVB
  module Excon
    module Instrument
      class Retry < Request
        def process
          Instrumentation.incr(:api_retry_count)
          Instrumentation.append_to_log(category => total_time)
          Rails.logger.info "#{message} - %.2fms" % [time_in_ms]
        end
      end
    end
  end
end
