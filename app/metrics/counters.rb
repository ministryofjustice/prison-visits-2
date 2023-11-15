module Counters
  class CountVisits < ActiveRecord::Base
    def self.fetch_and_format
      first.count
    end
  end

  class CountVisitsByState < ActiveRecord::Base
    def self.fetch_and_format
      pluck(:processing_state, :count).to_h
    end
  end

  class CountVisitsByPrisonAndState < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :processing_state, :count)
    end
  end

  class CountVisitsByPrisonAndCalendarWeek < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :week, :processing_state, :count)
    end
  end

  class CountVisitsByPrisonAndCalendarDate < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :month, :day, :processing_state, :count)
    end
  end
end
