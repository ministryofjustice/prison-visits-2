class MetricsController < ApplicationController
  before_action :authorize_prison_request

  def index
    @start_date = start_date_from_range

    if all_time?
      counts = all_time_counts
    else
      counts = weekly_counts(year: @start_date.year,
                             week: @start_date.cweek)
    end

    @dataset = MetricsPresenter.new(*counts)
  end

private

  def weekly_counts(year: nil, week: nil)
    counts = Counters::CountVisitsByPrisonAndCalendarWeek.
             where(year: year, week: week).fetch_and_format

    overdue = Overdue::CountOverdueVisitsByPrisonAndCalendarWeek.
              where(year: year, week: week).ordered_counters

    percentiles = Percentiles::DistributionByPrisonAndCalendarWeek.
                  where(year: year, week: week).ordered_counters

    rejections = Rejections::RejectionPercentageByPrisonAndCalendarWeek.
                 where(year: year, week: week).fetch_and_format

    [flatten_weekly_count(counts, year, week), overdue, percentiles,
     flatten_weekly_count(rejections, year, week)]
  end

  def flatten_weekly_count(data, year, week)
    data.each_with_object({}) do |(name, value), hash|
      hash[name] = value[year][week]
    end
  end

  def all_time_counts
    [Counters::CountVisitsByPrisonAndState.fetch_and_format,
     Overdue::CountOverdueVisitsByPrison.ordered_counters,
     Percentiles::DistributionByPrison.ordered_counters,
     Rejections::RejectionPercentageByPrison.fetch_and_format]
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
