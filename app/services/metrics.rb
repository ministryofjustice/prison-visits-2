require 'metrics/counter_support'

module Metrics
  class CountVisits < ActiveRecord::Base
    def self.run
      first.count
    end
  end

  class CountVisitsByState < ActiveRecord::Base
    def self.run
      all.each_with_object({}){ |counter, result|
        result[counter.processing_state] = counter.count
      }
    end
  end

  class CountVisitsByPrisonAndState < ActiveRecord::Base
    extend Metrics::CounterSupport
  end

  class CountVisitsByPrisonAndCalendarWeek < ActiveRecord::Base
    extend Metrics::CounterSupport
  end

  class CountVisitsByPrisonAndCalendarDate < ActiveRecord::Base
    extend Metrics::CounterSupport
  end
end
