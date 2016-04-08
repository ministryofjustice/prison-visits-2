class SlotAvailability
  attr_reader :slots

  def initialize(prison:, use_nomis_slots: false)
    @prison = prison
    @slots = lookup_slots_for_prison(prison, use_nomis_slots)
  end

  # rubocop:disable Metrics/MethodLength
  def lookup_slots_for_prison(prison, use_nomis)
    # Default to hard-coded slots if API is unavailable or returns an error
    if use_nomis && Nomis::Api.enabled?
      begin
        Nomis::Api.instance.fetch_bookable_slots(
          prison: prison,
          start_date: prison.first_bookable_date,
          end_date: prison.last_bookable_date
        )
      rescue Excon::Errors::Error => e
        Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
        prison.available_slots.to_a
      end
    else
      prison.available_slots.to_a
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def restrict_by_prisoner(prisoner_number:, prisoner_dob:)
    # Skip restriction if Nomis api is not enabled
    return unless Nomis::Api.enabled?

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
end
