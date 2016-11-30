module PercentileSerialisation
  extend ActiveSupport::Concern

  def as_json(*_args)
    {
      date: date,
      ninety_fifth_percentile: (percentiles.first.to_f / 1.day),
      median: (percentiles.last.to_f / 1.day)
    }
  end
end
