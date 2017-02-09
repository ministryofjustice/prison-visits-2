class PrisonSummaryMetricsPresenter
  def initialize(counts: nil,
    timings: nil,
    percentiles: nil,
    overdue_count: nil)

    @counts = counts
    @timings = timings
    @percentiles = percentiles
    @overdue_count = overdue_count
  end

  def processed_on_time
    processed('timely')
  end

  def processed_overdue
    processed('overdue')
  end

  def end_to_end_percentile(percentile)
    return 0 unless @percentiles

    key = percentile[/\d+/].to_i
    seconds = @percentiles[key]

    sprintf('%2.2f', seconds.to_f / 1.day)
  end

  def total_visits
    return 0 unless @counts
    @counts.values.sum
  end

  def visits_in_state(state)
    return 0 unless @counts
    @counts[state] || 0
  end

  def overdue_count
    return 0 unless @overdue_count
    @overdue_count['requested'] || 0
  end

  def percent_rejected
    return '0.0' if total_visits == 0

    rejected = BigDecimal.new(visits_in_state('rejected'))
    total = BigDecimal.new(total_visits)

    percentage = (rejected / total) * 100
    percentage.truncate(2)
  end

private

  def processed(type)
    return 0 unless @timings
    data = @timings.fetch(type, {})
    data.values.sum
  end
end
