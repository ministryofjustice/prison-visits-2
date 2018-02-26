class PrisonerDetailsPresenter
  VALID    = 'valid'.freeze
  INVALID  = 'invalid'.freeze
  NOT_LIVE = 'not_live'.freeze

  delegate :internal_location, to: :prisoner_location

  VALIDATION_ERRORS = [
    PrisonerValidation::UNKNOWN,
    PrisonerLocationValidation::INVALID
  ].freeze

  def initialize(prisoner_validation, prisoner_location)
    self.prisoner_validation = prisoner_validation
    self.prisoner_location   = prisoner_location
  end

  def prisoner_existance_status
    return NOT_LIVE unless Nomis::Api.enabled?
    return VALID    if valid?

    case prisoner_existance_error
    when nil
      VALID
    when *VALIDATION_ERRORS
      prisoner_existance_error
    else
      INVALID
    end
  end

  def details_incorrect?
    prisoner_existance_status == INVALID
  end

  def prisoner_existance_error
    prisoner_validation_errors.first
  end

  def prisoner_location_error
    prisoner_location_errors.first
  end

private

  attr_accessor :prisoner_validation, :prisoner_location

  def prisoner_validation_errors
    @prisoner_validation_errors ||= prisoner_validation.tap(&:valid?).errors.full_messages
  end

  def prisoner_location_errors
    @prisoner_location_errors ||= prisoner_location.tap(&:valid?).errors.full_messages
  end

  def valid?
    prisoner_validation.valid? && prisoner_location.valid?
  end
end
