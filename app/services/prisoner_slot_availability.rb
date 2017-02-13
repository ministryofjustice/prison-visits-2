class PrisonerSlotAvailability
  PRISONER_UNAVAILABLE = 'prisoner_unavailable'.freeze

  def initialize(prison, noms_id, date_of_birth, start_date, end_date)
    self.prison        = prison
    self.noms_id       = noms_id
    self.date_of_birth = date_of_birth
    self.start_date    = start_date
    self.end_date      = end_date
    self.api_error     = false
  end

  def slots
    if enforce_all_available_slots?
      return all_slots_available
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

  attr_accessor :prison, :noms_id, :date_of_birth, :start_date, :end_date, :api_error

  def offender
    @offender ||= Nomis::Api.instance.lookup_active_offender(
      noms_id: noms_id, date_of_birth: date_of_birth
    )
  end

  def all_slots_available
    results = Hash.new { |h, slot| h[slot] = [] }
    prison_slots.each_with_object(results) do |slot, slots_with_availabilities|
      slots_with_availabilities[slot.to_s]
    end
  end

  def prison_slots
    @prison_slots ||= AvailableSlotEnumerator.new(
      start_date, end_date, prison.recurring_slots,
      prison.anomalous_slots, prison.unbookable_dates
    ).to_a
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

  def offender_availabilities_dates
    @offender_availabilities_dates ||= offender_availabilities[:dates]
  end

  def enforce_all_available_slots?
    !offender.valid? || (load_offender_availabilities && api_error)
  end
end
