class PrisonerAvailabilityValidation
  include NonPersistedModel

  PRISONER_AVAILABILITY_UNKNOWN = 'prisoner_availibility_unknown'.freeze
  PRISONER_NOT_AVAILABLE = 'prisoner_not_available'.freeze

  attribute :offender, Nomis::Offender
  attribute :requested_dates, Array[Date]

  validate :slots_availability

  def date_error(date)
    errors[date.to_s].first
  end

private

  def slots_availability
    requested_dates.each do |requested_date|
      error_message = error_message_for_slot(requested_date)
      errors[requested_date.to_s] << error_message if error_message
    end
  end

  def error_message_for_slot(date)
    unless Nomis::Api.enabled? && offender_availability
      return PRISONER_AVAILABILITY_UNKNOWN
    end

    PRISONER_NOT_AVAILABLE unless offender_availability.include?(date)
  end

  def offender_availability
    return nil unless offender.valid?

    @offender_availability ||= load_offender_availability
  end

  def load_offender_availability
    return nil if @prisoner_availability_error

    Nomis::Api.instance.offender_visiting_availability(
      offender_id: offender.id,
      start_date:  requested_dates.min,
      end_date:    requested_dates.max
    ).dates
  rescue Nomis::NotFound => e
    @prisoner_availability_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end
end
