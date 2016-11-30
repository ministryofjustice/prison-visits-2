namespace :pvb do
  namespace :metrics do
    desc 'refresh materialized views'
    task refresh: :environment do
      VisitCountsByPrisonStateDateAndTimely.refresh
      PercentilesByCalendarDate.refresh
      PercentilesByPrisonAndCalendarDate.refresh
      RejectionPercentageByDay.refresh
    end
  end
end
