# Gets prisoner and slot availability details from NOMIS.
class StaffNomisChecker
  def initialize(visit)
    @visit = visit
  end

  def prisoner_availability_unknown?
    prisoner_availability_validation.unknown_result?
  end

  def slot_availability_unknown?
    Nomis::Feature.slot_availability_enabled?(@visit.prison_name) &&
      slot_availability_validation.unknown_result?
  end

  def prisoner_restrictions_unknown?
    Nomis::Feature.restrictions_info_enabled?(@visit.prison_name) &&
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
    prisoner_contact_list.unknown_result?
  end

  def approved_contacts
    prisoner_contact_list.approved
  end

  def offender
    @offender ||= load_offender
  end

  def prisoner_restrictions
    if Nomis::Feature.restrictions_info_enabled?(@visit.prison_name) &&
        offender.valid?
      prisoner_restriction_list.active
    else
      []
    end
  end

private

  def slot_prisoner_restrictions(slot)
    if Nomis::Feature.restrictions_enabled? && offender.valid?
      prisoner_restriction_list.on_slot(slot)
    else
      []
    end
  end

  def prisoner_availability_errors(slot)
    if offender.valid?
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

  def prisoner_contact_list
    @prisoner_contact_list ||= PrisonerContactList.new(offender)
  end

  def prisoner_restriction_list
    @prisoner_restriction_list ||= PrisonerRestrictionList.new(offender)
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

  def load_offender
    if Nomis::Api.enabled?
      Nomis::Api.instance.lookup_active_prisoner(
        noms_id:       @visit.prisoner_number,
        date_of_birth: @visit.prisoner.date_of_birth
      )
    else
      Nomis::NullPrisoner.new
    end
  end
end
