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

  desc 'Backpopulate visitors on visit state changes'
  task backpopulate_visitors: :environment do
    VisitStateChange.
      where(to_state: 'withdrawn').
      includes(visit: :visitors).find_each do |vs|
        vs.update_column(:visitor_id, vs.visit.principal_visitor.id)
      end

    VisitStateChange.
      includes(visit: :visitors).
      where(to_state: 'cancelled',
            reason: Cancellation::VISITOR_CANCELLED).find_each do |vs|
      vs.update_column(:visitor_id, vs.visit.principal_visitor.id)
    end
  end
end
