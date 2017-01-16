# frozen_string_literal: true
class MetricsPresenter
  def initialize(counts:, overdue_counts:, percentiles:, rejections:, timings:)
    @counts = counts
    @overdue_counts = overdue_counts
    @percentiles = percentiles
    @rejections = rejections
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

  def end_to_end_percentile(prison_name, percentile)
    summary_for(prison_name).end_to_end_percentile(percentile)
  end

  def percent_rejected(prison_name, reason)
    summary_for(prison_name).percent_rejected(reason)
  end

  def summary_for(prison_name)
    @summaries[prison_name] ||= build_summary_for(prison_name)
  end

  def build_summary_for(prison_name)
    counts = @counts[prison_name]
    overdue_count = @overdue_counts[prison_name]
    percentiles = @percentiles[prison_name]
    rejections = @rejections[prison_name]
    timings = @timings[prison_name]

    PrisonSummaryMetricsPresenter.new(counts: counts,
                                      overdue_count: overdue_count,
                                      percentiles: percentiles,
                                      rejections: rejections,
                                      timings: timings)
  end
end
