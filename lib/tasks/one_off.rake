namespace :pvb do

  desc 'Merge Isle Of Wight Prisons'
  task merge_iow: :environment do
    albany    = Estate.find_by!(nomis_id: 'ALI').prisons.first
    parkhurst = Estate.find_by!(nomis_id: 'IWI').prisons.first

    while FeedbackSubmission.where(prison_id: albany.id).any?
      FeedbackSubmission.
        where(prison_id: albany.id).
        limit(1000).
        update_all(prison_id: parkhurst.id)
    end

    while Visit.where(prison_id: albany.id).any?
      Visit.
        where(prison_id: albany.id).
        limit(1000).
        update_all(prison_id: parkhurst.id)
    end
  end

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
      includes(visit: %i[cancellation visitors]).
      where(visit_state: 'cancelled',
            'cancellations.reason': Cancellation::VISITOR_CANCELLED).
      find_each do |vs|
      vs.update_column(:visitor_id, vs.visit.principal_visitor.id)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/AssignmentInCondition
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
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
                          select { |s| s.to_date > Time.zone.today }.
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

  def check_slot_availability(client, visit)
    retry_count = 0
    # API has a bug where the start date is not inclusive and must be later than
    # today, this means that we can only check slots 2 days from today so if the
    # API fails it could be because of that.
    current_slots = visit.slots.select { |s| s.to_date > 1.day.from_now.to_date }

    return if current_slots.empty?

    begin
      response = client.get(
        "/prison/#{visit.nomis_id}/slots",
        start_date: current_slots.min.to_date - 1.day, # API bug workaround
        end_date: current_slots.max.to_date)

      availability = Nomis::SlotAvailability.new(response)

      if availability.none? { |slot| slot.in?(current_slots) }
        SlotAvailabilityCounter.inc_unavailable_visit
      end
    rescue Nomis::APIError => e
      if retry_count < 5
        if e.class.name.match?(/Exception/)
          retry_count += 1
          SlotAvailabilityCounter.inc_api_failure
          retry
        else
          SlotAvailabilityCounter.inc_bad_range
        end
      else
        SlotAvailabilityCounter.inc_hard_failures
      end
    end
    nil
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
            msg = task.call(client, data)
            if msg
              STDOUT.print msg.to_json + "\n"
            end
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
    require 'instrumentation'

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

  desc 'Check slot availability for requested visits'
  task check_slot_availability: :environment do
    require 'highline'

    cli = HighLine.new

    prison_name = cli.ask("Prison name or 'all': ")

    pool = ConnectionPool.new(size: 2, timeout: 60) do
      Nomis::Client.new(Rails.configuration.nomis_api_host,
        Rails.configuration.nomis_api_token,
        Rails.configuration.nomis_api_key)
    end

    if prison_name == 'all'
      Prison.enabled.pluck('name').sort.each do |name|
        if Rails.
            configuration.
            staff_prisons_with_slot_availability.include?(name)
          next
        end
        check_estate_slot_availability(pool, name)
        SlotAvailabilityCounter.reset
      end
    else
      check_estate_slot_availability(pool, prison_name)
    end
  end

  def check_estate_slot_availability(pool, prison_name)
    queue = Queue.new
    task = ->(client, visit) { check_slot_availability(client, visit) }

    visits = Visit.select('visits.*', 'estates.nomis_id nomis_id').
             joins(prison: :estate).
             where(processing_state: 'requested').
             where(prisons: { name: prison_name })

    non_expired = visits.select { |visit|
      visit.slots.all? { |s| s.to_date > Time.zone.today }
    }

    non_expired.each do |visit| queue << visit end

    workers = 2.times.map { new_worker(pool, queue, task) }
    workers.map(&:join)

    STDOUT.puts "Prison: #{prison_name}"
    STDOUT.puts "Visits checked: #{non_expired.size}"
    STDOUT.puts \
      "Visits unavailable: #{SlotAvailabilityCounter.unavailable_visits}"
    STDOUT.puts "Retries: #{SlotAvailabilityCounter.retries}"
    STDOUT.puts "Bad range: #{SlotAvailabilityCounter.bad_range}"
    STDOUT.puts "Unchecked: #{SlotAvailabilityCounter.hard_failures}"
    STDOUT.puts ''
  end

  desc 'Populate visits friendly id'
  task populate_visits_human_id: :environment do
    require 'human_readable_id'

    query = Visit.where(human_id: nil).limit(1000)
    batch = query.pluck(:id)
    while batch.any?
      batch.each do |id|
        HumanReadableId.update_unique_id(Visit, id, :human_id)
      end

      batch = query.pluck(:id)
    end
  end

  desc 'Rename IoW SSO organisation name'
  task rename_iow_sso_org_name: :environment do
    iow = Estate.find_by!(nomis_id: 'IWI')
    iow.update!(sso_organisation_name: 'isle_of_wight.prisons.noms.moj')
  end

  desc 'Delete Albany'
  task delete_albany: :environment do
    albany = Estate.find_by!(nomis_id: 'ALI')
    Estate.transaction do
      albany.prisons.destroy_all
      albany.destroy!
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/AssignmentInCondition
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
end

class SlotAvailabilityCounter
  @unavailable_visits = 0
  @retries = 0
  @hard_failures = 0
  @bad_range = 0

  @mutex = Mutex.new

  class << self
    attr_reader :retries, :hard_failures, :unavailable_visits, :bad_range
  end

  def self.inc_unavailable_visit
    @mutex.synchronize do
      @unavailable_visits += 1
    end
  end

  def self.inc_retries
    @mutex.synchronize do
      @retries += 1
    end
  end

  def self.inc_hard_failures
    @mutex.synchronize do
      @hard_failures += 1
    end
  end

  def self.inc_bad_range
    @mutex.synchronize do
      @bad_range += 1
    end
  end

  def self.reset
    @unavailable_visits = 0
    @retries = 0
    @hard_failures = 0
    @bad_range = 0
  end
end
