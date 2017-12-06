require 'support/counter_support'

module Metrics
  class Formatter
    include CounterSupport

    def initialize(ordered_counters)
      self.ordered_counters = ordered_counters
    end

  private

    attr_accessor :ordered_counters
  end
end
