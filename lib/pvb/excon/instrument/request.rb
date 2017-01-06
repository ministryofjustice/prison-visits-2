module PVB
  module Excon
    module Instrument
      class Request
        include Instrument

        def process
          Instrumentation.incr(:api_request_count)
          Instrumentation.append_to_log(category => total_time)
          Rails.logger.info "#{message} – %.2fms" % [time_in_ms]
        end

        def time_in_ms
          (finish - start) * 1000
        end

        def category
          :api
        end

        def message
          "Calling NOMIS API: #{payload[:method].to_s.upcase} #{payload[:path]}"
        end

        def total_time
          Instrumentation.custom_log_items[category].to_i + time_in_ms
        end
      end
    end
  end
end
