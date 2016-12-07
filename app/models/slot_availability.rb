class SlotAvailability
  attr_reader :slots

  def initialize(prison:, use_nomis_slots: false)
    @prison = prison
    @slots = (use_nomis_slots && nomis_slots(prison)) || hardcoded_slots(prison)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def restrict_by_prisoner(prisoner_number:, prisoner_dob:)
    # Skip restriction if prisoner availability is enabled
    return unless public_prisoner_availability_enabled?

    offender = Nomis::Api.instance.lookup_active_offender(
      noms_id: prisoner_number,
      date_of_birth: prisoner_dob
    )

    availability = Nomis::Api.instance.offender_visiting_availability(
      offender_id: offender.id,
      start_date: @prison.first_bookable_date,
      end_date: @prison.last_bookable_date
    )
    offender_available_dates = availability.dates

    @slots = @slots.select { |slot|
      slot.to_date.in? offender_available_dates
    }
  rescue Excon::Errors::Error => e
    # Skip restriction if NOMIS API is misbehaving
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
  end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize

private

  def hardcoded_slots(prison)
    prison.available_slots.to_a
  end

  def nomis_slots(prison)
    return nil unless public_prisoner_availability_enabled?

    Nomis::Api.instance.fetch_bookable_slots(
      prison: prison,
      start_date: prison.first_bookable_date,
      end_date: prison.last_bookable_date
    )
  rescue Excon::Errors::Error => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

  def public_prisoner_availability_enabled?
    Nomis::Api.enabled? &&
      Rails.configuration.nomis_public_prisoner_availability_enabled
  end
end
