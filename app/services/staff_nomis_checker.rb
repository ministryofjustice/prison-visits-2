# Gets prisoner and slot availability details from NOMIS.
class StaffNomisChecker
  VALID    = 'valid'.freeze
  INVALID  = 'invalid'.freeze
  UNKNOWN  = 'unknown'.freeze
  NOT_LIVE = 'not_live'.freeze

  LOCATION_VALID    = 'location_valid'.freeze
  LOCATION_INVALID  = 'location_invalid'.freeze
  LOCATION_UNKNOWN  = 'location_unknown'.freeze

  def initialize(visit)
    @visit = visit
  end

  def prisoner_existance_status
    return NOT_LIVE unless Nomis::Api.enabled?
    case prisoner_existance_error
    when nil
      VALID
    when UNKNOWN, LOCATION_INVALID, LOCATION_UNKNOWN
      prisoner_existance_error
    else
      INVALID
    end
  end

  def prisoner_details_incorrect?
    prisoner_existance_status == INVALID
  end

  def prisoner_existance_error
    return prisoner_validation_errors.first if prisoner_validation_errors.first
    return LOCATION_INVALID if prisoner_moved?
  end

  def prisoner_availability_unknown?
    Nomis::Feature.prisoner_availability_enabled? &&
      prisoner_availability_validation.unknown_result?
  end

  def slot_availability_unknown?
    Nomis::Feature.slot_availability_enabled?(@visit.prison_name) &&
      slot_availability_validation.unknown_result?
  end

  def prisoner_restrictions_unknown?
    Nomis::Feature.offender_restrictions_enabled? &&
      prisoner_restriction_list.unknown_result?
  end

  def errors_for(slot)
    prisoner_availability_errors(slot) +
      slot_availability_errors(slot) +
      slot_prisoner_restrictions(slot)
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

  def contact_list_unknown?
    Nomis::Feature.contact_list_enabled?(@visit.prison_name) &&
      prisoner_contact_list.unknown_result?
  end

  def approved_contacts
    prisoner_contact_list.approved
  end

  def offender
    @offender ||= Nomis::Api.instance.lookup_active_offender(
      noms_id:       @visit.prisoner_number,
      date_of_birth: @visit.prisoner.date_of_birth
    )
  end

  def prisoner_restrictions
    if Nomis::Feature.offender_restrictions_info_enabled?(@visit.prison_name) &&
        offender.valid?
      prisoner_restriction_list.active
    else
      []
    end
  end

private

  def slot_prisoner_restrictions(slot)
    if Nomis::Feature.offender_restrictions_enabled? && offender.valid?
      prisoner_restriction_list.on_slot(slot)
    else
      []
    end
  end

  def prisoner_availability_errors(slot)
    if Nomis::Feature.prisoner_availability_enabled? && offender.valid?
      prisoner_availability_validation.slot_errors(slot)
    else
      []
    end
  end

  def slot_availability_errors(slot)
    if Nomis::Feature.slot_availability_enabled?(@visit.prison_name)
      [slot_availability_validation.slot_error(slot)].compact
    else
      []
    end
  end

  def prisoner_validation_errors
    @prisoner_validation_errors ||= prisoner_validation.errors.full_messages
  end

  def prisoner_contact_list
    @prisoner_contact_list ||= PrisonerContactList.new(offender)
  end

  def prisoner_restriction_list
    @prisoner_restriction_list ||= PrisonerRestrictionList.new(offender)
  end

  def prisoner_validation
    @prisoner_validation ||= PrisonerValidation.new(offender).tap(&:valid?)
  end

  def prisoner_moved?
    @prisoner_moved ||= !prisoner_validation.prisoner_located_at?(@visit.prison.nomis_id)
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
end
