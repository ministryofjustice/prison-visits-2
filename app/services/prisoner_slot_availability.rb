class PrisonerSlotAvailability
  PRISONER_UNAVAILABLE = 'prisoner_unavailable'.freeze

  def initialize(prison, offender, start_date, end_date)
    self.prison     = prison
    self.offender   = offender
    self.start_date = start_date
    self.end_date   = end_date
    self.api_error  = false
  end

  def slots
    if !offender.valid? || (load_offender_availabilities && api_error)
      return all_slots_available_enforced
    end

    results = Hash.new { |h, slot| h[slot] = [] }
    prison_slots.each_with_object(results) do |slot, slots_with_availabilities|
      slots_with_availabilities[slot.to_s]
      unless offender_availabilities_dates.delete(slot.to_date)
        slots_with_availabilities[slot.to_s] << PRISONER_UNAVAILABLE
      end
    end
  end

private

  attr_accessor :prison, :offender, :start_date, :end_date, :api_error

  def all_slots_available_enforced
    results = Hash.new { |h, slot| h[slot] = [] }
    prison_slots.each_with_object(results) do |slot, slots_with_availabilities|
      slots_with_availabilities[slot.to_s]
    end
  end

  def offender_availabilities
    @offender_availabilities ||= Nomis::Api.instance.offender_visiting_availability(
      offender_id: offender.id, start_date: start_date, end_date: end_date
    )
  rescue Nomis::APIError => e
    self.api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    []
  end
  alias_method :load_offender_availabilities, :offender_availabilities

  def prison_slots
    @prison_slots ||= AvailableSlotEnumerator.new(
      prison.first_bookable_date(Date.current),
      prison.last_bookable_date(60.days.from_now),
      prison.recurring_slots,
      prison.anomalous_slots,
      prison.unbookable_dates
    ).to_a
  end

  def offender_availabilities_dates
    @offender_availabilities_dates ||= offender_availabilities[:dates]
  end

  def enforce_all_slot_available?
    !offender.valid? || api_error
  end
end
