# frozen_string_literal: true
namespace :pvb do
  desc 'Withdraw expired visits'
  task withdraw_expired_visits: :environment do
    require 'highline'
    cli = HighLine.new

    estate_name = cli.ask("Estate name ('all' to cancel all visits): ")
    estate = estate_name == 'all' ? nil : Estate.find_by!(name: estate_name)

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
  # rubocop:disable Style/RescueModifier
  def check_prisoner_details(client, number, dob)
    RequestStore.store[:custom_log_items] = {}
    log = { noms_id: number }

    begin
      response = client.get('/lookup/active_offender',
        noms_id: number,
        date_of_birth: dob)

      log[:found] = !!response['found']
    rescue Nomis::APIError => e
      log[:error] = e.message
    end

    log[:timing] = RequestStore.store[:custom_log_items][:api]
    log
  end

  def new_worker(pool, queue, thread_number)
    Thread.new do
      request_id = "check_prisoner_details_#{thread_number}"
      RequestStore.store[:request_id] = request_id

      begin
        while job = queue.pop(true) rescue nil
          number, dob = job
          pool.with do |client|
            STDOUT.print check_prisoner_details(client, number, dob).to_json + "\n"
          end
        end
      rescue ThreadError => e
        error_msg = { thread_error: true, message: e.message }.to_json
        STDOUT.print error_msg + "\n"
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/AssignmentInCondition
  # rubocop:enable Style/RescueModifier

  desc 'Check vists prisoner details in Nomis'
  task check_prisoner_details: :environment do
    require 'highline'
    require 'instrumentation'

    cli = HighLine.new

    to_private_key = lambda do |str|
      der = Base64.decode64(str)
      OpenSSL::PKey::EC.new(der)
    end

    nomis_key = cli.ask('Nomis api key: ', to_private_key) { |q|
      q.echo = '*'
    }

    nomis_token = cli.ask('Nomis token: ') { |q| q.echo = '*' }

    nomis_host = cli.ask('Nomis host: ')
    days_to_check = cli.ask('Number of days to check: ', Integer)

    data = Prisoner.
           where('created_at > ?', days_to_check.days.ago).
           pluck(:number, :date_of_birth).
           uniq

    queue = Queue.new
    data.each do |pair| queue << pair end
    STDOUT.puts "Checking #{queue.size} prisoners"
    STDOUT.print "\n"

    pool = ConnectionPool.new(size: 5, timeout: 60) do
      Nomis::Client.new(nomis_host, nomis_token, nomis_key)
    end

    workers = 1.upto(10).map { |i| new_worker(pool, queue, i) }
    workers.map(&:join)
  end
end
