require 'logstash_sidekiq_logger'

log_file = Rails.root.join("log/logstash_#{Rails.env}.log")

LogstashSidekiqLogger.setup(log_file)
