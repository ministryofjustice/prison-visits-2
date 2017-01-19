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
      where(visit_state: 'withdrawn').
      includes(visit: :visitors).find_each do |vs|
        vs.update_column(:visitor_id, vs.visit.principal_visitor.id)
      end

    VisitStateChange.
      includes(visit: [:cancellation, :visitors]).
      where(visit_state: 'cancelled',
            'cancellations.reason': Cancellation::VISITOR_CANCELLED).
      find_each do |vs|
      vs.update_column(:visitor_id, vs.visit.principal_visitor.id)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/AssignmentInCondition
  # rubocop:disable Metrics/AbcSize
  def check_prisoner_availability(client, visit)
    RequestStore.store[:custom_log_items] = {}

    log = {}
    begin
      response = client.get('/lookup/active_offender',
        noms_id: visit.pnumber,
        date_of_birth: visit.pdob)

      if !!response['found']
        offender_id = response['offender']['id']
        potential_dates = visit.slots.
                          select { |s| s.to_date >= Time.zone.today }.
                          map(&:to_date)

        response = client.get(
          "/offenders/#{offender_id}/visits/available_dates",
          start_date: potential_dates.min, end_date: potential_dates.max)

        log[:prisoner_availability] = sprintf('%2.0f', response['dates'].size)
      else
        log[:found] = false
      end
    rescue Nomis::APIError => e
      log[:error] = e.message
    end
    log[:timing] = sprintf('%8.04f', RequestStore.store[:custom_log_items][:api])
    log[:visit] = visit.id
    log[:prison] = visit.pname
    log
  end

  def new_worker(pool, queue, task)
    Thread.new do
      begin
        while data = begin
                       queue.pop(true)
                     rescue
                       nil
                     end
          pool.with do |client|
            RequestStore.store[:custom_log_items] = {}
            STDOUT.print task.call(client, data).to_json + "\n"
          end
        end
      rescue ThreadError => e
        error_msg = { thread_error: true, message: e.message }.to_json
        STDOUT.print error_msg + "\n"
      end
    end
  end

  desc 'Check prisoner availability for requested visits'
  task check_prisoner_availability: :environment do
    pool = ConnectionPool.new(size: 5, timeout: 60) do
      Nomis::Client.new(Rails.configuration.nomis_api_host,
        Rails.configuration.nomis_api_token,
        Rails.configuration.nomis_api_key)
    end
    queue = Queue.new
    task = ->(client, visit) { check_prisoner_availability(client, visit) }

    Visit.select('visits.*',
      'prisoners.number pnumber',
      'prisoners.date_of_birth pdob',
      'prisons.name pname').
      joins(:prisoner, :prison).
      where(processing_state: 'requested').
      order('prisons.name').
      find_in_batches do |batch|
      batch.each { |pair| queue << pair }
    end

    workers = 10.times.map { new_worker(pool, queue, task) }
    workers.map(&:join)
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/AssignmentInCondition
  # rubocop:enable Metrics/AbcSize
end
