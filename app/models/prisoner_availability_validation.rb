class PrisonerAvailabilityValidation
  include NonPersistedModel

  PRISONER_NOT_AVAILABLE = 'prisoner_not_available'.freeze

  attribute :offender, Nomis::Offender
  attribute :requested_dates, Array[Date]

  validate :slots_availability

  def date_error(date)
    errors[date.to_s].first
  end

  def unknown_result?
    !Nomis::Api.enabled? || offender_availability.nil? || api_error
  end

private

  attr_reader :api_error

  def slots_availability
    valid_requested_dates.each do |requested_date|
      error_message = error_message_for_slot(requested_date)
      errors[requested_date.to_s] << error_message if error_message
    end
  end

  def error_message_for_slot(date)
    return if unknown_result?

    PRISONER_NOT_AVAILABLE unless offender_availability.include?(date)
  end

  def offender_availability
    return nil unless offender.valid?
    # Don't want to show prisoner unavailable errors for invalid dates
    return requested_dates unless valid_requested_dates.any?

    @offender_availability ||= load_offender_availability
  end

  def load_offender_availability
    return nil if @api_error

    Nomis::Api.instance.offender_visiting_availability(
      offender_id: offender.id,
      start_date:  valid_requested_dates.min,
      end_date:    valid_requested_dates.max
    ).dates
  rescue Nomis::APIError => e
    @api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

  def valid_requested_dates
    @valid_dates ||= requested_dates.select { |date|
      date >= Date.current && date <= 60.days.from_now.to_date
    }
  end
end
