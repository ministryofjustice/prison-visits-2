module PVB
  module Excon
    module Instrument
      class Request
        include Instrument

        def process
          # Store the name of the api to instrument the outcome of the api call
          RequestStore.store[:nomis_api_name] = payload[:path].split('/').last

          instrument_request
          Rails.logger.info "#{message} - %.2fms" % [time_in_ms]
        end

      private

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

        def instrument_request
          # Set to false initialially, error instrumenter reverses this
          Instrumentation.append_to_log(api_call_error => false)
          Instrumentation.incr(:api_request_count)
          Instrumentation.append_to_log(category => total_time)
        end
      end
    end
  end
end
