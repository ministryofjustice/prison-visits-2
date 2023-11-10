class MetricsPresenter
  def initialize(counts:, timings:)
    @counts = counts
    @timings = timings
    @summaries = {}
  end

  def total_visits(prison_name)
    summary_for(prison_name).total_visits
  end

  def visits_in_state(prison_name, state)
    summary_for(prison_name).visits_in_state(state)
  end

  def overdue_count(prison_name)
    summary_for(prison_name).processed_overdue
  end

  def percent_rejected(prison_name)
    summary_for(prison_name).percent_rejected
  end

  def summary_for(prison_name)
    @summaries[prison_name] ||= build_summary_for(prison_name)
  end

  def build_summary_for(prison_name)
    counts = @counts[prison_name]
    timings = @timings[prison_name]

    PrisonSummaryMetricsPresenter.new(counts:,
                                      timings:)
  end
end
