module PercentileSerialisation
  extend ActiveSupport::Concern

  def as_json(*_args)
    {
      date:,
      ninety_fifth_percentile: (percentiles.first / 1.day.to_f),
      median: (percentiles.last / 1.day.to_f)
    }
  end
end
