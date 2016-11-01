namespace :pvb do
  desc 'Withdraw expired visits'
  task withdraw_expired_visits: :environment do
    require 'highline'
    cli = HighLine.new

    estate_name = cli.ask("Estate name ('all' to cancel all visits): ")
    estate = (estate_name == 'all') ? nil : Estate.find_by!(name: estate_name)

    requested_visits = Visit.with_processing_state(:requested)

    if estate
      requested_visits = requested_visits.
                         joins(prison: :estate).
                         where(estates: { name: estate.name })
    end

    withdrawn_count = 0
    requested_visits.find_each do |visit|
      if visit.slots.all? { |s| s.to_date <= Time.zone.today }
        visit.withdraw!
        withdrawn_count += 1
        if withdrawn_count % 100 == 0
          STDOUT.puts "Witdrawn #{withdrawn_count}..."
        end
      end
    end

    STDOUT.puts "Done. Withdrawn #{withdrawn_count} expired visits."
  end

  namespace :db do
    namespace :migrate do
      desc 'Migrate rejection from single reason to multiple reasons'
      task rejection: :environment do
        Rejection.transaction do
          Rejection::REASONS.each do |reason|
            ActiveRecord::Base.
              connection.
              execute <<-SQL
UPDATE rejections
SET reasons = array_append(reasons, '#{reason}')
WHERE reason  = '#{reason}'
  AND reasons = '{}'
SQL
          end
        end
      end
    end
  end
end
