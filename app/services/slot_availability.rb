class SlotAvailability
  PRISONER_UNAVAILABLE = 'prisoner_unavailable'.freeze
  PRISON_UNAVAILABLE   = 'prison_unavailable'.freeze

  def initialize(prison, noms_id, date_of_birth,
    date_range = Time.zone.today.to_date..28.days.from_now)
    @prison = prison
    @noms_id = noms_id
    @date_of_birth = date_of_birth
    @start_date = date_range.min
    @end_date = calculate_end_date(date_range)
    @offender_availability_error = false
  end

  def slots
    load_offender_availabilities if nomis_public_prisoner_availability_enabled? && offender.valid?

    slots_and_unavailabiltiy_reasons
  end

private

  attr_reader :prison, :noms_id, :date_of_birth,
    :start_date, :end_date, :offender_availability_error

  def slots_and_unavailabiltiy_reasons
    all_slots.deep_dup.each do |slot, unavailability_reasons|
      if nomis_public_prisoner_availability_enabled? &&
          offender.valid? &&
          !offender_availability_error &&
          !offender_availabilities_dates.include?(slot.to_date)
        unavailability_reasons << PRISONER_UNAVAILABLE
      end

      if live_availability_enabled? && !bookable_prison_slots.include?(slot)
        unavailability_reasons << PRISON_UNAVAILABLE
      end
    end
  end

  def offender
    @offender ||= Nomis::Api.instance.lookup_active_offender(
      noms_id: noms_id, date_of_birth: date_of_birth
    )
  end

  def all_slots
    @all_slots ||= Hash[prison_slots.map { |slot| [slot.to_s, []] }]
  end

  def prison_slots
    @prison_slots ||= prison.available_slots(start_date)
  end

  def bookable_prison_slots
    @bookable_prison_slots ||=
      begin
        api_slot_availability = ApiSlotAvailability.new(
          prison: prison, use_nomis_slots: true)
        api_slot_availability.slots.map(&:time)
      end
  end

  def offender_availabilities
    @offender_availabilities ||= Nomis::Api.instance.offender_visiting_availability(
      offender_id: offender.id, start_date: start_date, end_date: end_date
    )
  rescue Nomis::APIError => e
    @offender_availability_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    []
  end
  alias_method :load_offender_availabilities, :offender_availabilities

  def offender_availabilities_dates
    @offender_availabilities_dates ||= offender_availabilities[:dates]
  end

  def nomis_public_prisoner_availability_enabled?
    Nomis::Api.enabled? &&
      Rails.configuration.nomis_public_prisoner_availability_enabled
  end

  def calculate_end_date(date_range)
    # ensures the range does not go over the 28 days constraint
    [date_range.min + 28.days, date_range.max].min
  end

  def live_availability_enabled?
    Rails.configuration.public_prisons_with_slot_availability.include?(
      prison.name
    )
  end
end
