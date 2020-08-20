class ApiSlotAvailability
  attr_reader :slots

  def initialize(prison:, use_nomis_slots: true)
    @prison = prison
    @slots = (use_nomis_slots && nomis_slots(prison)) || hardcoded_slots(prison)
  end

  def prisoner_available_dates(prisoner_number:, prisoner_dob:)
    return unless Nomis::Api.enabled?

    prisoner = Nomis::Api.instance.lookup_active_prisoner(
      noms_id: prisoner_number,
      date_of_birth: prisoner_dob
    )

    availability = Nomis::Api.instance.prisoner_visiting_availability(
      offender_id: prisoner.nomis_offender_id,
      start_date: @prison.first_bookable_date,
      end_date: @prison.last_bookable_date
    )
    availability.dates
  rescue Excon::Errors::Error => e
    # Skip restriction if NOMIS API is misbehaving
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

private

  def hardcoded_slots(prison)
    prison.available_slots.to_a
  end

  def nomis_slots(prison)
    return nil if !Nomis::Api.enabled? || !public_prison_slots_enabled?(prison)

    Nomis::Api.instance.fetch_bookable_slots(
      prison: prison,
      start_date: prison.first_bookable_date,
      end_date: prison.last_bookable_date
    ).slots.map(&:time)
  rescue Excon::Errors::Error => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

  def public_prison_slots_enabled?(prison)
    Rails.configuration.public_prisons_with_slot_availability&.include?(prison.name)
  end
end
