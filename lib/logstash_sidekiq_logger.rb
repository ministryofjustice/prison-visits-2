# Sets up a new sidekiq file logger for logstash consumption.
#
# To do this it combines data from ActiveJob notifications and from Sidekiq
# logs.
#
# ActiveJob notifications provides data on what job ran with what parameters,
# this is obtained by setting up a subscription to the ActiveJob instrumentaton
# that Rails provides.
#
# Sidekiq provides no instrumentation so the ActiveJob data is combined on a
# custom log formatter.
#
# The final output looks like:
#
# (as single lines in the log file, output generated from
# LogstashSidekiqLogger::Formatter#extract_log_data)
#
# {
#   "job_name":"prison_mailer_request_received",
#   "arguments":["gid://prison-visits/Visit/0125d92d-3e27-4835-bc35-7fd5fb"],
#   "queue_name":"mailers",
#   "job_status":"completed",
#   "active_job_duration":640.827,
#   "total_duration":691.0,
#   "message":"[completed] 691.0 ms prison_mailer_request_received arguments
#   "@timestamp":"2016-06-17T13:22:58.096Z",
#   "@version":"1"
# }
#
# {
#   "job_name":"prison_mailer_request_received",
#   "arguments":["gid://prison-visits/Visit/0125d92d-3e27-4835-bc35-7fd5fb"],
#   "queue_name":"mailers",
#   "job_status":"to_be_retried",
#   "active_job_duration":1.194,
#   "total_duration":4.0,
#   "message":"[to_be_retried] 4.0 ms prison_mailer_request_received arguments
#   "retry_number":1,
#   "@timestamp":"2016-06-17T13:00:26.298Z",
#   "@version":"1"
# }

require_relative 'logstash_sidekiq_logger/active_job_subscriber'
require_relative 'logstash_sidekiq_logger/formatter'

# Remove when we enable it again
# :nocov:
module LogstashSidekiqLogger
  def self.setup(log_file)
    # Listen to Rails ActiveJob instrumentation
    ActiveJobSubscriber.attach_to :active_job

    custom_sidekiq_logger = ActiveSupport::Logger.new(log_file)
    custom_sidekiq_logger.formatter = Formatter.new

    # ActiveSupport::Logger.broadcast wraps an existing logger so that logs
    # going to that logger get broadcasted to a different logger
    Sidekiq
      .logger
      .extend(ActiveSupport::Logger.broadcast(custom_sidekiq_logger))
  end
end
