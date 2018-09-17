class PrisonerLocationPresenter
  include Nomis::ApiEnabledGuard

  delegate :internal_location, to: :prisoner_location_validation

  def initialize(prisoner_location_validation)
    self.prisoner_location_validation = prisoner_location_validation
  end

  check_nomis_enabled
  def status
    return if prisoner_location_validation.valid?

    prisoner_location_validation.errors.full_messages.first
  end

private

  attr_accessor :prisoner_location_validation
end
