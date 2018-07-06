class PrisonerAvailabilityValidation
  include MemoryModel

  PRISONER_ERRORS = [
    Nomis::Offender::DateAvailability::BANNED,
    Nomis::Offender::DateAvailability::OUT_OF_VO,
    Nomis::Offender::DateAvailability::EXTERNAL_MOVEMENT,
    Nomis::Offender::DateAvailability::BOOKED_VISIT
  ].freeze

  attribute :offender, :nomis_offender
  attribute :requested_slots, :concrete_slot_list

  validate :slots_availability

  def slot_errors(slot)
    errors[slot.to_s]
  end

  def unknown_result?
    return false if valid_requested_slots.none?
    !Nomis::Api.enabled? || offender_availability.nil? || api_error
  end

private

  attr_reader :api_error

  def slots_availability
    valid_requested_slots.each do |requested_slot|
      error_messages_for_slot(requested_slot).each do |message|
        errors[requested_slot.to_s] << message
      end
    end
  end

  def error_messages_for_slot(slot)
    return [] if unknown_result? || !valid_slot?(slot)

    offender_availability.error_messages_for_slot(slot)
  end

  def offender_availability
    return nil unless offender.valid?

    @offender_availability ||= load_offender_availability
  end

  def load_offender_availability
    return nil if @api_error

    Nomis::Api.instance.offender_visiting_detailed_availability(
      offender_id: offender.id,
      slots: valid_requested_slots
    )
  rescue Nomis::APIError => e
    @api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

  def valid_requested_slots
    @valid_requested_slots ||= requested_slots.select { |slot| valid_slot?(slot) }
  end

  def valid_slot?(slot)
    slot.to_date.between?(Date.tomorrow, 60.days.from_now.to_date)
  end
end
