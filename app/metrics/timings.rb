module Timings
  class TimelyAndOverdue < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :status, :count)
    end
  end

  class TimelyAndOverdueByCalendarWeek < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :week, :status, :visit_state, :count)
    end
  end
end
