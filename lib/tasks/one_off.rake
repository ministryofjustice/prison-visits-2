namespace :pvb do
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/AssignmentInCondition
  # rubocop:disable Metrics/PerceivedComplexity
  def check_slot_availability(client, visit)
    retry_count = 0
    # API has a bug where the start date is not inclusive and must be later than
    # today, this means that we can only check slots 2 days from today so if the
    # API fails it could be because of that.
    current_slots = visit.slots.select { |s| s.to_date > 1.day.from_now.to_date }

    return if current_slots.empty?

    begin
      response = client.get(
        "/prison/#{visit.prison.estate.nomis_id}/slots",
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
      while data = begin
        queue.pop(true)
      rescue ThreadError
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

  def check_estate_slot_availability(pool, prison_name)
    queue = Queue.new
    task = ->(client, visit) { check_slot_availability(client, visit) }

    visits = Visit.
        includes(:prison).
        where(processing_state: 'requested').
        where(prisons: { name: prison_name })

    non_expired = visits.select { |visit|
      visit.slots.all? { |s| s.to_date > Time.zone.today }
    }

    SlotAvailabilityCounter.visits_checked = non_expired.size

    non_expired.each do |visit|
      queue << visit
    end

    workers = 2.times.map { new_worker(pool, queue, task) }
    workers.map(&:join)
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/AssignmentInCondition
  # rubocop:enable Metrics/PerceivedComplexity

  desc 'Email slot availability for outstanding prisons'
  task email_slot_availability: :environment do
    pool = ConnectionPool.new(size: 2, timeout: 60) do
      Nomis::Client.new(Rails.configuration.nomis_api_host,
        Rails.configuration.nomis_api_token,
        Rails.configuration.nomis_api_key)
    end

    prison_data = {}

    Prison.enabled.pluck('name').sort.each do |name|
      if Rails.
          configuration.
          staff_prisons_with_slot_availability.include?(name)
        next
      end
      check_estate_slot_availability(pool, name)

      prison_data[name] = {
        visits_checked: SlotAvailabilityCounter.visits_checked,
        unavailable_visits: SlotAvailabilityCounter.unavailable_visits,
        retries: SlotAvailabilityCounter.retries,
        hard_failures: SlotAvailabilityCounter.retries,
        bad_range: SlotAvailabilityCounter.bad_range
      }

      SlotAvailabilityCounter.reset
    end

    AdminMailer.slot_availability(prison_data).deliver_now!
  end
end

class SlotAvailabilityCounter
  @unavailable_visits = 0
  @retries = 0
  @hard_failures = 0
  @bad_range = 0
  @visits_checked = 0

  @mutex = Mutex.new

  class << self
    attr_reader :retries, :hard_failures, :unavailable_visits, :bad_range
    attr_accessor :visits_checked
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
    @visits_checked = 0
  end
end
