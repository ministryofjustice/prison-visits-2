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

  def prisoner_existance_error
    prisoner_validation.errors[:base].first
  end

  def prisoner_availability_unknown?
    prisoner_availability_enabled? &&
      prisoner_availability_validation.unknown_result?
  end

  def errors_for(slot)
    return [] unless prisoner_availability_enabled? && offender.valid?

    [
      prisoner_availability_validation.date_error(slot.to_date)
    ].compact
  end

private

  def prisoner_availability_enabled?
    @nomis_api_enabled &&
      Rails.configuration.nomis_staff_prisoner_availability_enabled
  end

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
        requested_dates: @visit.slots.map(&:to_date)).tap(&:valid?)
  end

  def offender
    @offender ||= Nomis::Api.instance.lookup_active_offender(
      noms_id:       @visit.prisoner_number,
      date_of_birth: @visit.prisoner.date_of_birth
    )
  end
end
