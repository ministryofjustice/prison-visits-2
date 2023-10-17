class SlotAvailabilityValidation
  include MemoryModel

  SLOT_NOT_AVAILABLE = 'slot_not_available'.freeze

  attribute :requested_slots, :concrete_slot_list

  validate :slots_availability

  attr_accessor :prison

  def slot_error(slot)
    errors[slot.to_s].first
  end

  def unknown_result?
    !Nomis::Api.enabled? || prison_availability.nil? || api_error
  end

private

  attr_reader :api_error

  def slots_availability
    valid_requested_slots.each do |requested_slot|
      error_message = error_message_for_slot(requested_slot)
      errors.add(requested_slot.to_s.to_sym, error_message) if error_message
    end
  end

  def error_message_for_slot(slot)
    return if unknown_result?

    SLOT_NOT_AVAILABLE unless prison_availability.map(&:time).include?(slot)
  end

  def prison_availability
    # Don't want to show prisoner unavailable errors for invalid dates
    return requested_slots if valid_requested_slots.none?

    @prison_availability ||= load_prison_availability
  end

  def load_prison_availability
    return nil if @api_error

    Nomis::Api.instance.fetch_bookable_slots(
      prison: prison,
      start_date: valid_requested_slots.min.to_date,
      end_date: valid_requested_slots.max.to_date)
      .slots
  rescue Nomis::APIError => e
    @api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end

  def valid_requested_slots
    @valid_requested_slots ||=
      begin
        min = Date.tomorrow
        max = 60.days.from_now.to_date
        requested_slots.select { |slot| slot.to_date.between?(min, max) }
      end
  end
end
