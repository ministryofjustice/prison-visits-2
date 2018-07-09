class PrisonerAvailabilityValidation
  include MemoryModel

  PRISONER_ERRORS = [
    Nomis::PrisonerDateAvailability::BANNED,
    Nomis::PrisonerDateAvailability::OUT_OF_VO,
    Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT,
    Nomis::PrisonerDateAvailability::BOOKED_VISIT
  ].freeze

  attribute :prisoner, :nomis_offender
  attribute :requested_slots, :concrete_slot_list

  validate :slots_availability

  def slot_errors(slot)
    errors[slot.to_s]
  end

  def unknown_result?
    return false if valid_requested_slots.none?
    !Nomis::Api.enabled? || prisoner_availability.nil? || api_error
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

    prisoner_availability.error_messages_for_slot(slot)
  end

  def prisoner_availability
    return nil unless prisoner.valid?

    @prisoner_availability ||= load_prisoner_availability
  end

  def load_prisoner_availability
    return nil if @api_error

    Nomis::Api.instance.prisoner_visiting_detailed_availability(
      offender_id: prisoner.id,
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
