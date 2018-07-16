class PrisonerValidation
  UNKNOWN            = 'unknown'.freeze
  PRISONER_NOT_EXIST = 'prisoner_does_not_exist'.freeze

  include ActiveModel::Validations
  validate :active_prisoner_exists

  def initialize(prisoner)
    self.prisoner = prisoner
    self.api_error = false
  end

private

  attr_accessor :prisoner, :api_error

  def active_prisoner_exists
    unless Nomis::Api.enabled? && prisoner.api_call_successful?
      errors.add :base, UNKNOWN
      return
    end

    unless prisoner.valid?
      errors.add :base, PRISONER_NOT_EXIST
    end
  end
end
