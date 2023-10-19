module LogstashSidekiqLogger
  class Formatter < Logger::Formatter
    def call(_severity, _time, _program_name, message)
      store_message_failure_metadata(message)

      performed_job = RequestStore.store[:performed_job]
      return unless performed_job && message_needs_logging?(message)

      data = extract_log_data(performed_job, message)
      event = LogStash::Event.new(data)

      RequestStore.clear!

      "\n#{event.to_json}"
    end

  private

    # rubocop:disable Performance/RegexpMatch
    def store_message_failure_metadata(message)
      return unless message =~ /^fail/

      duration = message.match(/^fail:\s(.*)\s/).captures.first
      RequestStore.store[:duration] = duration.to_f * 1000 # milliseconds
    end
    # rubocop:enable Performance/RegexpMatch

    def failure_data(message)
      { retry_count: message['retry_count'] }
    end

    def extract_log_data(performed_job, message)
      data = base_log_data(performed_job, message)
      data.merge!(failure_data(message)) unless data[:status] == 'completed'
      data[:message] = log_message(data)
      data
    end

    def log_message(data)
      msg = "[#{data[:job_status]}] (#{data[:total_duration]} ms) "
      msg + "#{data[:job_name]} args: #{data[:arguments]}"
    end

    def base_log_data(performed_job, message)
      {
        job_name: job_name(performed_job),
        arguments: job_arguments(performed_job),
        queue_name: queue_name(performed_job),
        job_status: calculate_status(message),
        active_job_duration: active_job_duration(performed_job),
        total_duration: total_duration(message)
      }
    end

    def job_name(job)
      arguments = job.payload[:job].arguments
      job_class_name = arguments.first.underscore
      method_name = arguments.second

      "#{job_class_name}_#{method_name}"
    end

    def job_arguments(job)
      arguments = job.payload[:job].arguments
      arguments[2..].map do |arg|
        arg.try(:to_global_id).try(:to_s) || arg.to_s
      end
    end

    def queue_name(job)
      job.payload[:job].queue_name
    end

    def calculate_status(message)
      if message.is_a?(Hash)
        if message['retry']
          'to_be_retried'
        else
          'failed'
        end
      else
        'completed'
      end
    end

    def active_job_duration(job)
      job.duration # milliseconds
    end

    def total_duration(message)
      RequestStore.store[:duration] || extract_duration(message)
    end

    # Message duration is in seconds, convert to milliseconds
    def extract_duration(message)
      message.match(/\s(.+)\s/).captures.first.to_f * 1000
    end

    # Sidekiq logs a Hash with metadata about a failure, otherwise it is a
    # string.
    def message_needs_logging?(message)
      (message.is_a?(Hash) && message.key?('class')) ||
        message =~ /^done/
    end
  end
end
