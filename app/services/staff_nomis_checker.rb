class StaffNomisChecker
  VALID = 'valid'.freeze
  INVALID = 'invalid'.freeze
  UNKNOWN = 'unknown'.freeze
  NOT_LIVE = 'not_live'.freeze

  def initialize(visit)
    @visit = visit
    @nomis_api_enabled = Nomis::Api.enabled?
  end

  def prisoner_existance_status
    return NOT_LIVE unless @nomis_api_enabled
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

private

  def prisoner_validation
    @prisoner_validation ||=
      PrisonerValidation.new(
        noms_id: @visit.prisoner_number,
        date_of_birth: @visit.prisoner.date_of_birth).tap(&:valid?)
  end
end
