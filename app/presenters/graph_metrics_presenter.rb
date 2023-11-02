class GraphMetricsPresenter
  def percentiles_by_day
    @percentiles_by_day ||= PercentilesByCalendarDate.order(date: :asc)
  end

  def percentiles_by_day_for(prison)
    PercentilesByPrisonAndCalendarDate.where(prison_id: prison.id)
  end

  def visits_per_processing_state
    @visits_per_processing_state ||= begin
      query = visit_count_per_state_scope
              .sum(:count)
      format_stat_collection(query, Metrics::ProcessingState)
    end
  end

  def visits_per_processing_state_for(prison)
    @visits_per_processing_state_for ||= begin
      query = visit_count_per_state_scope
              .where(prison_id: prison.id)
              .sum(:count)
      format_stat_collection(query, Metrics::ProcessingState)
    end
  end

  def timely_and_overdue
    @timely_and_overdue ||= begin
      query = timely_and_overdue_scope
              .sum(:count)
      format_stat_collection(query, Metrics::TimelyVisitsCount)
    end
  end

  def timely_and_overdue_for(prison)
    query = timely_and_overdue_scope
            .where(prison_id: prison.id)
            .sum(:count)
    format_stat_collection(query, Metrics::TimelyVisitsCount)
  end

  def rejection_percentages
    @rejection_percentages ||= begin
      query = rejection_percentages_scope
              .sum(:percentage)
      format_stat_collection(query, Metrics::RejectionPercentage)
    end
  end

  def rejection_percentages_for(prison)
    query = rejection_percentages_scope
            .where(prison_id: prison.id)
            .sum(:percentage)
    format_stat_collection(query, Metrics::RejectionPercentage)
  end

private

  def visit_count_per_state_scope
    VisitCountsByPrisonStateDateAndTimely
      .group(:date, :processing_state)
      .order(:date, :processing_state)
  end

  def timely_and_overdue_scope
    VisitCountsByPrisonStateDateAndTimely
      .group(:date, :timely)
      .order(:date, :timely)
      .where(processing_state: %w[booked rejected])
  end

  def rejection_percentages_scope
    RejectionPercentageByDay
      .where.not(reason: 'total')
      .order(date: :asc)
      .group(:date, :reason)
  end

  def format_stat_collection(query, presenter_class)
    metrics_presenters = Hash.new do |h, date|
      h[date] = presenter_class.new(date: date)
    end

    query.each do |(date, stat), count|
      metrics_presenters[date].public_send("#{stat}=", count)
    end
    metrics_presenters.values
  end
end
