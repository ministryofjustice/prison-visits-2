module Instrumentation
  class << self
    def append_to_log(payload)
      RequestStore.store[:custom_log_items] ||= {}
      RequestStore.store[:custom_log_items].merge!(payload)
    end

    def custom_log_items
      RequestStore.store[:custom_log_items] || {}
    end

    def time_and_log(message, category = nil)
      fail 'Block required' unless block_given?

      result, time_in_ms = time_action { yield }

      Rails.logger.info "#{message} – %.2fms" % [time_in_ms]

      if category
        total_time = time_in_ms + custom_log_items[category].to_i
        append_to_log(category => total_time)
      end
      result
    end

  private

    def time_action
      started_at = Time.now.utc
      result = yield
      finished_at = Time.now.utc
      time_in_ms = (finished_at - started_at) * 1000
      [result, time_in_ms]
    end
  end
end
