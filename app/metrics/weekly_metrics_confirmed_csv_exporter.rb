require 'csv'
require 'formatter'

class WeeklyMetricsConfirmedCsvExporter
  def initialize(dates_to_export = nil)
    self.dates = dates_to_export || default_dates(weeks: 12)
  end

  def to_csv
    CSV.generate(headers: headers, write_headers: true) do |csv|
      Prison.enabled.each do |prison|
        csv << prison_data(prison)
      end
    end
  end

private

  attr_accessor :dates

  def headers
    ['Prison'] + @dates.map(&:to_s)
  end

  def default_dates(weeks:)
    current_week = Time.zone.today.beginning_of_week

    1.upto(weeks).map { |n| current_week - n.weeks }
  end

  def prison_data(prison)
    row = { 'Prison' => prison.name }

    @dates.each do |date|
      prison_data = counts.fetch(prison.name, {})
      year_data = prison_data.fetch(date.year, {})
      week_data = year_data.fetch(date.cweek, {})
      bookings = week_data.fetch('booked', 0)

      row[date.to_s] = bookings
    end
    row
  end

  def counts
    @counts ||= load_counts
  end

  def load_counts
    metrics_formatter = Metrics::Formatter.new(ordered_counts)
    metrics_formatter.fetch_and_format
  end

  def ordered_counts
    min_date = @dates.min
    max_date = @dates.max + 6.days

    if min_date.year != max_date.year
      min_counts = Counters::CountVisitsByPrisonAndCalendarWeek
        .where('year = ? AND week >= ?', min_date.year, min_date.cweek)
        .pluck(:prison_name, :year, :week, :processing_state, :count)

      max_counts = Counters::CountVisitsByPrisonAndCalendarWeek
        .where('year = ? AND week <= ?', max_date.year, max_date.cweek)
        .pluck(:prison_name, :year, :week, :processing_state, :count)

      min_counts + max_counts
    else
      Counters::CountVisitsByPrisonAndCalendarWeek
        .where('year = ? AND week >= ?', min_date.year, min_date.cweek)
        .where('year = ? AND week <= ?', max_date.year, max_date.cweek)
        .pluck(:prison_name, :year, :week, :processing_state, :count)
    end
  end
end
