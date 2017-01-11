# frozen_string_literal: true
module LogstashSidekiqLogger
  class ActiveJobSubscriber < ActiveSupport::LogSubscriber
    def perform(event)
      RequestStore.store[:performed_job] = event
    end
  end
end
