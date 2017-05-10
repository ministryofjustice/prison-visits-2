class PrisonerValidation
  UNKNOWN                   = 'unknown'.freeze
  PRISONER_NOT_EXIST        = 'prisoner_does_not_exist'.freeze
  PRISONER_LOCATION_INVALID = 'location_invalid'.freeze
  PRISONER_LOCATION_UNKNOWN = 'location_unknown'.freeze

  include ActiveModel::Validations
  validate :active_offender_exists

  def initialize(offender)
    self.offender = offender
    self.api_error = false
  end

  def prisoner_located_at?(prison_code)
    prisoner_location.code == prison_code
  end

private

  attr_accessor :offender, :api_error

  # rubocop:disable Metrics/MethodLength
  def active_offender_exists
    unless Nomis::Api.enabled? && offender.api_call_successful?
      errors.add :base, UNKNOWN
      return
    end

    unless offender.valid?
      errors.add :base, PRISONER_NOT_EXIST
      return
    end

    unless prisoner_location.api_call_successful?
      errors.add :base, PRISONER_LOCATION_UNKNOWN
    end
  end
  # rubocop:enable Metrics/MethodLength

  def prisoner_location
    @prisoner_location ||= load_prisoner_location
  end

  def load_prisoner_location
    Nomis::Api.instance.lookup_offender_location(noms_id: offender.noms_id)
  rescue Nomis::APIError => e
    Raven.capture_exception(
      e, fingerprint: %w[nomis lookup_offender_location_error])
    PVB::Instrumentation.append_to_log(lookup_offender_location: false)
    Nomis::Establishment.new(api_call_successful: false)
  end
end
