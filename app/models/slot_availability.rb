class SlotAvailability
  attr_reader :slots

  def initialize(prison:)
    @prison = prison
    @slots = prison.available_slots.to_a
  end

  # rubocop:disable Metrics/MethodLength
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
  end
  # rubocop:enable Metrics/MethodLength
end
