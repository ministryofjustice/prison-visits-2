require 'support/counter_support'

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
  end

  class CountVisitsByPrisonAndCalendarWeek < ActiveRecord::Base
    extend CounterSupport
  end

  class CountVisitsByPrisonAndCalendarDate < ActiveRecord::Base
    extend CounterSupport
  end
end
