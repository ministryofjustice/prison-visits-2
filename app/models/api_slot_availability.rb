class ApiSlotAvailability
  attr_reader :slots

  def initialize(prison:, use_nomis_slots: true, start_date: Time.zone.today, end_date: Time.zone.today + 30.days)
    @prison = prison
    @slots = (use_nomis_slots && nomis_slots(prison, prison.first_bookable_date(start_date), end_date)) || hardcoded_slots(prison)
  end

  def prisoner_available_dates(prisoner_number:, prisoner_dob:, start_date:)
    return unless Nomis::Api.enabled?

    prisoner = Nomis::Api.instance.lookup_active_prisoner(
      noms_id: prisoner_number,
      date_of_birth: prisoner_dob
    )

    availability = Nomis::Api.instance.prisoner_visiting_availability(
      offender_id: prisoner.nomis_offender_id,
      start_date: @prison.first_bookable_date(start_date),
      end_date: @prison.last_bookable_date(start_date)
    )
    availability.dates
  rescue Excon::Errors::Error => e
    # Skip restriction if NOMIS API is misbehaving
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

private

  def calculate_end_date(date_range)
    # ensures the range does not go over the 28 days constraint
    [date_range.min + 28.days, date_range.max].min
  end

  def hardcoded_slots(prison)
    prison.available_slots.to_a
  end

  def nomis_slots(prison, start_date, end_date)
    Nomis::Api.instance.fetch_bookable_slots(
      prison:,
      start_date:,
      end_date: calculate_end_date(start_date..end_date)
    ).slots.map(&:time)
  rescue Excon::Errors::Error => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end
end
