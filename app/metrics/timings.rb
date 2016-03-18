require 'support/counter_support'

module Timings
  class TimelyAndOverdue < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :status, :visit_state, :count)
    end
  end
end
