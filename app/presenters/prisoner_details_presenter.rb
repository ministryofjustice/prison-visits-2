class PrisonerDetailsPresenter
  VALID    = 'valid'.freeze
  INVALID  = 'invalid'.freeze
  NOT_LIVE = 'not_live'.freeze

  delegate :internal_location, to: :prisoner_location

  VALIDATION_ERRORS = [
    PrisonerValidation::UNKNOWN
  ].freeze

  def initialize(prisoner_validation)
    self.prisoner_validation = prisoner_validation
  end

  def prisoner_existance_status
    return NOT_LIVE unless Nomis::Api.enabled?
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

  def prisoner_validation_errors
    @prisoner_validation_errors ||= prisoner_validation.tap(&:valid?).errors.full_messages
  end

private

  attr_accessor :prisoner_validation, :prisoner_location
end
