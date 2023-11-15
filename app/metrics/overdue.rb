module Overdue
  class CountOverdueVisits < ActiveRecord::Base
    extend CounterSupport
    def self.fetch_and_format
      pluck(:visit_state, :count).to_h
    end
  end

  class CountOverdueVisitsByPrison < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :visit_state, :count)
    end
  end

  class CountOverdueVisitsByPrisonAndCalendarWeek < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :week, :visit_state, :count)
    end
  end

  class CountOverdueVisitsByPrisonAndCalendarDate < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :month, :day, :visit_state, :count)
    end
  end
end
