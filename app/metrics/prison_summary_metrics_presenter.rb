class PrisonSummaryMetricsPresenter
  def initialize(counts: nil, timings: nil)
    @counts = counts
    @timings = timings
  end

  def processed_overdue
    processed('overdue')
  end

  def total_visits
    return 0 unless @counts

    @counts.values.sum
  end

  def visits_in_state(state)
    return 0 unless @counts

    @counts[state] || 0
  end

  def percent_rejected
    return '0.0' if total_visits == 0

    rejected = BigDecimal(visits_in_state('rejected'))
    total = BigDecimal(total_visits)

    percentage = (rejected / total) * 100
    percentage.truncate(2)
  end

private

  def processed(type)
    return 0 unless @timings

    @timings.fetch(type, 0)
  end
end
