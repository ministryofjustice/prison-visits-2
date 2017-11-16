class PrisonerValidation
  UNKNOWN            = 'unknown'.freeze
  PRISONER_NOT_EXIST = 'prisoner_does_not_exist'.freeze

  include ActiveModel::Validations
  validate :active_offender_exists

  def initialize(offender)
    self.offender = offender
    self.api_error = false
  end

private

  attr_accessor :offender, :api_error

  def active_offender_exists
    unless Nomis::Api.enabled? && offender.api_call_successful?
      errors.add :base, UNKNOWN
      return
    end

    unless offender.valid?
      errors.add :base, PRISONER_NOT_EXIST
    end
  end
end
