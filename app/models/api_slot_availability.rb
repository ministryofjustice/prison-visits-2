class ApiSlotAvailability
  attr_reader :slots

  def initialize(prison:, use_nomis_slots: false)
    @prison = prison
    @slots = (use_nomis_slots && nomis_slots(prison)) || hardcoded_slots(prison)
  end

  # rubocop:disable Metrics/MethodLength
  def restrict_by_prisoner(prisoner_number:, prisoner_dob:)
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
    prisoner_available_dates = availability.dates

    @slots = @slots.select { |slot|
      slot.to_date.in? prisoner_available_dates
    }
  rescue Excon::Errors::Error => e
    # Skip restriction if NOMIS API is misbehaving
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
  end
# rubocop:enable Metrics/MethodLength

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
    )
  rescue Excon::Errors::Error => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

  def public_prison_slots_enabled?(_prison)
    true
  end
end
