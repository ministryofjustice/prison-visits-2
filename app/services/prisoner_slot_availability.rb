class PrisonerSlotAvailability
  PRISONER_UNAVAILABLE = 'prisoner_unavailable'.freeze

  def initialize(prison, noms_id, date_of_birth,
    date_range = Time.zone.today.to_date..28.days.from_now)
    self.prison        = prison
    self.noms_id       = noms_id
    self.date_of_birth = date_of_birth
    self.start_date    = date_range.min
    self.end_date      = date_range.max
    self.api_error     = false
  end

  def slots
    return all_slots if enforce_all_available_slots?

    results = all_slots.deep_dup.each { |slot, unavailability_reasons|
      unless offender_availabilities_dates.include?(slot.to_date)
        unavailability_reasons << PRISONER_UNAVAILABLE
      end
    }

    results
  end

private

  attr_accessor :prison, :noms_id, :date_of_birth, :start_date, :end_date, :api_error

  def offender
    @offender ||= Nomis::Api.instance.lookup_active_offender(
      noms_id: noms_id, date_of_birth: date_of_birth
    )
  end

  def all_slots
    @all_slots ||= Hash[prison_slots.map { |slot| [slot.to_s, []] }]
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
    !nomis_public_prisoner_availability_enabled? ||
      !offender.valid? ||
      (load_offender_availabilities && api_error)
  end

  def nomis_public_prisoner_availability_enabled?
    Nomis::Api.enabled? &&
      Rails.configuration.nomis_public_prisoner_availability_enabled
  end
end
