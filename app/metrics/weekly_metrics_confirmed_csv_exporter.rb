class WeeklyMetricsConfirmedCsvExporter
  def initialize(weeks:)
    @counts = Counters::CountVisitsByPrisonAndCalendarWeek.fetch_and_format
    @dates = dates_to_export(weeks: weeks)
  end

  def to_csv
    CSV.generate(headers: headers, write_headers: true) do |csv|
      Prison.enabled.each do |prison|
        csv << prison_data(prison)
      end
    end
  end

private

  def headers
    ['Prison'] + @dates.map(&:to_s)
  end

  def dates_to_export(weeks:)
    current_week = Time.zone.today.beginning_of_week

    1.upto(weeks).map { |n| current_week - n.weeks }
  end

  def prison_data(prison)
    row = { 'Prison' => prison.name }

    @dates.each do |date|
      prison_data = @counts.fetch(prison.name, {})
      year_data = prison_data.fetch(date.year, {})
      week_data = year_data.fetch(date.cweek, {})
      bookings = week_data.fetch('booked', 0)

      row[date.to_s] = bookings
    end
    row
  end
end
