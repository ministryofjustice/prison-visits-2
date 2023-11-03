module Percentiles
  class Distribution < ActiveRecord::Base
    extend PercentileSupport
    def self.fetch_and_format
      hash_centiles(first.percentiles)
    end
  end

  class DistributionByPrison < ActiveRecord::Base
    extend PercentileSupport
    def self.ordered_counters
      pluck(:prison_name, :percentiles)
    end
  end

  class DistributionByPrisonAndCalendarWeek < ActiveRecord::Base
    extend PercentileSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :week, :percentiles)
    end
  end

  class DistributionByPrisonAndCalendarDate < ActiveRecord::Base
    extend PercentileSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :month, :day, :percentiles)
    end
  end
end
