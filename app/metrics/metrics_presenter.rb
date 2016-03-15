class MetricsPresenter
  PERCENTILES_INDEX = {
    '99th' => 0,
    '95th' => 1,
    '90th' => 2,
    '75th' => 3,
    '50th' => 4,
    '25th' => 5
  }

  def initialize(counts, overdue_counts, percentiles)
    @counts = counts
    @overdue_counts = overdue_to_h(overdue_counts)
    @percentiles = percentiles_to_h(percentiles)
  end

  def total_visits(prison_name)
    prison_counts = @counts[prison_name]
    return 0 unless prison_counts

    prison_counts.values.sum
  end

  def visits_in_state(prison_name, state)
    prison_counts = @counts[prison_name]
    return 0 unless prison_counts

    prison_counts[state] || 0
  end

  def overdue_count(prison_name)
    @overdue_counts[prison_name] || 0
  end

  def end_to_end_percentile(prison_name, percentile)
    prison_percentiles = @percentiles[prison_name]
    return 0 unless prison_percentiles

    index = PERCENTILES_INDEX.fetch(percentile)
    seconds = prison_percentiles[index]

    sprintf('%2.2f', seconds.to_f / 1.day)
  end

private

  def overdue_to_h(counts)
    counts.each_with_object({}) { |count, hash| hash[count[0]] = count[2] }
  end

  def percentiles_to_h(percentiles)
    percentiles.each_with_object({}) do |count, hash|
      hash[count[0]] = count[-1]
    end
  end
end
