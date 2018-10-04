namespace :pvb do
  namespace :metrics do
    desc 'refresh materialized views'
    task refresh: :environment do
      Rails.logger.info 'Beginning metrics update'
      VisitCountsByPrisonStateDateAndTimely.refresh
      PercentilesByCalendarDate.refresh
      PercentilesByPrisonAndCalendarDate.refresh
      RejectionPercentageByDay.refresh
      Rails.logger.info 'Completed metrics update'
    end
  end
end
