class MetricsController < ApplicationController
  before_action :authorize_prison_request

  def index
    @start_date = start_date_from_range

    if all_time?
      metrics_counts = all_time_counts
    else
      metrics_counts = weekly_counts(@start_date)
    end

    @dataset = MetricsPresenter.new(metrics_counts)
  end

  def confirmed_bookings
    exporter = WeeklyMetricsConfirmedCsvExporter.new(weeks: 12)

    respond_to do |format|
      format.csv { render csv: exporter, filename: 'weekly_booking_stats' }
    end
  end

  def summary
    @prison = Prison.find(params[:prison_id])
    @date = 1.week.ago.beginning_of_week.to_date

    @summary = PrisonSummaryMetricsPresenter.
               new(summary_counts(@prison.name, @date))
  end

private

  def summary_counts(prison, date)
    {
      counts: week_counts(date)[prison],
      timings: week_timings(date)[prison],
      percentiles: week_percentiles(date)[prison]
    }
  end

  def week_counts(date)
    counts = Counters::CountVisitsByPrisonAndCalendarWeek.
             where(year: date.year, week: date.cweek).fetch_and_format

    flatten_weekly_count(counts, date.year, date.cweek)
  end

  def week_timings(date)
    timings = Timings::TimelyAndOverdueByCalendarWeek.
              where(year: date.year, week: date.cweek).fetch_and_format

    flatten_weekly_count(timings, date.year, date.cweek)
  end

  def week_percentiles(date)
    percentiles = Percentiles::DistributionByPrisonAndCalendarWeek.
                  where(year: date.year, week: date.cweek).
                  fetch_and_format

    flatten_weekly_count(percentiles, date.year, date.cweek)
  end

  def week_overdue_counts(date)
    overdue = Overdue::CountOverdueVisitsByPrisonAndCalendarWeek.
              where(year: date.year, week: date.cweek).fetch_and_format

    flatten_weekly_count(overdue, date.year, date.cweek)
  end

  def week_rejections(date)
    rejections = Rejections::RejectionPercentageByPrisonAndCalendarWeek.
                 where(year: date.year, week: date.cweek).fetch_and_format

    flatten_weekly_count(rejections, date.year, date.cweek)
  end

  def weekly_counts(date)
    {
      counts: week_counts(date),
      overdue_counts: week_overdue_counts(date),
      percentiles: week_percentiles(date),
      rejections: week_rejections(date)
    }
  end

  def flatten_weekly_count(data, year, week)
    data.each_with_object({}) do |(name, value), hash|
      hash[name] = value[year][week]
    end
  end

  def all_time_counts
    {
      counts: Counters::CountVisitsByPrisonAndState.fetch_and_format,
      overdue_counts: Overdue::CountOverdueVisitsByPrison.fetch_and_format,
      percentiles: Percentiles::DistributionByPrison.fetch_and_format,
      rejections: Rejections::RejectionPercentageByPrison.fetch_and_format
    }
  end

  def start_date_from_range
    if all_time?
      nil
    else
      1.week.ago.to_date
    end
  end

  def all_time?
    params[:range] == 'all_time'
  end
end
