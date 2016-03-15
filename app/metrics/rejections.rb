require 'support/counter_support'

module Rejections
  class RejectionPercentage < ActiveRecord::Base
    def self.fetch_and_format
      pluck(:reason, :percentage).to_h
    end
  end

  class RejectionPercentageByPrison < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :reason, :percentage)
    end
  end

  class RejectionPercentageByPrisonAndCalendarWeek < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :week, :reason, :percentage)
    end
  end

  class RejectionPercentageByPrisonAndCalendarDate < ActiveRecord::Base
    extend CounterSupport
    def self.ordered_counters
      pluck(:prison_name, :year, :month, :day, :reason, :percentage)
    end
  end
end
