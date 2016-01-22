require 'support/percentile_support'

module Percentiles
  class Distribution < ActiveRecord::Base
    extend PercentileSupport
    def self.fetch_and_format
      hash_centiles(first.percentiles)
    end
  end

  class DistributionByPrison < ActiveRecord::Base
    extend PercentileSupport
  end

  class DistributionByPrisonAndCalendarWeek < ActiveRecord::Base
    extend PercentileSupport
  end

  class DistributionByPrisonAndCalendarDate < ActiveRecord::Base
    extend PercentileSupport
  end
end
