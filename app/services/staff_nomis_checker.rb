# Gets prisoner and slot availability details from NOMIS.
class StaffNomisChecker
  VALID    = 'valid'.freeze
  INVALID  = 'invalid'.freeze
  UNKNOWN  = 'unknown'.freeze
  NOT_LIVE = 'not_live'.freeze

  def initialize(visit)
    @visit = visit
    @nomis_api_enabled = Nomis::Api.enabled?
  end

  def prisoner_existance_status
    return NOT_LIVE unless prisoner_check_enabled?

    case prisoner_existance_error
    when nil
      VALID
    when UNKNOWN
      UNKNOWN
    else
      INVALID
    end
  end

  def prisoner_details_incorrect?
    prisoner_existance_status == INVALID
  end

  def prisoner_existance_error
    prisoner_validation.errors[:base].first
  end

  def prisoner_availability_unknown?
    prisoner_availability_enabled? &&
      prisoner_availability_validation.unknown_result?
  end

  def slot_availability_unknown?
    slot_availability_enabled? &&
      slot_availability_validation.unknown_result?
  end

  def errors_for(slot)
    errors = []

    if prisoner_availability_enabled? && offender.valid?
      prisoner_availability_validation.slot_errors(slot).each do |error|
        errors << error
      end
    end

    if slot_availability_enabled?
      errors << slot_availability_validation.slot_error(slot)
    end

    errors.compact
  end

  def prisoner_availability_enabled?
    @nomis_api_enabled &&
      Rails.configuration.nomis_staff_prisoner_availability_enabled
  end

  def slot_availability_enabled?
    @nomis_api_enabled &&
      Rails.configuration.nomis_staff_slot_availability_enabled &&
      Rails.
        configuration.
        staff_prisons_with_slot_availability.include?(@visit.prison_name)
  end

  def slots_unavailable?
    @visit.slots.all? do |s|
      s.to_date <= Date.current ||
        errors_for(s).include?(SlotAvailabilityValidation::SLOT_NOT_AVAILABLE)
    end
  end

  def no_allowance?(slot)
    errors_for(slot).include?(Nomis::PrisonerDateAvailability::OUT_OF_VO)
  end

  def prisoner_banned?(slot)
    errors_for(slot).include?(Nomis::PrisonerDateAvailability::BANNED)
  end

  def prisoner_out_of_prison?(slot)
    errors_for(slot).include?(Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT)
  end

private

  def prisoner_check_enabled?
    @nomis_api_enabled &&
      Rails.configuration.nomis_staff_prisoner_check_enabled
  end

  def prisoner_validation
    @prisoner_validation ||= PrisonerValidation.new(offender).tap(&:valid?)
  end

  def prisoner_availability_validation
    @prisoner_availability_validation ||=
      PrisonerAvailabilityValidation.new(
        offender: offender,
        requested_slots: @visit.slots).tap(&:valid?)
  end

  def slot_availability_validation
    @slot_availability_validation ||=
      SlotAvailabilityValidation.new(
        prison: @visit.prison,
        requested_slots: @visit.slots).
      tap(&:valid?)
  end

  def offender
    @offender ||= Nomis::Api.instance.lookup_active_offender(
      noms_id:       @visit.prisoner_number,
      date_of_birth: @visit.prisoner.date_of_birth
    )
  end
end
