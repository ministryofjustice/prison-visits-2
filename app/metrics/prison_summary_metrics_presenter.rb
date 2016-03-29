class PrisonSummaryMetricsPresenter
  def initialize(counts: nil,
    timings: nil,
    percentiles: nil,
    overdue_count: nil,
    rejections: nil)

    @counts = counts
    @timings = timings
    @percentiles = percentiles
    @overdue_count = overdue_count
    @rejections = rejections
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

  def percent_rejected(reason)
    return '0' unless @rejections

    @rejections.fetch(reason, 0).to_s
  end

private

  def processed(type)
    return 0 unless @timings
    data = @timings.fetch(type, {})
    data.values.sum
  end
end
