require 'support/percentile_support'

module Percentiles
  class CalculateDistributions < ActiveRecord::Base
    extend PercentileSupport
    def self.fetch_and_format
      Hash[centiles.zip(first.percentiles)]
    end
  end

  class CalculateDistributionsForPrisons < ActiveRecord::Base
    extend PercentileSupport
    def self.fetch_and_format
      first
    end
  end
end
