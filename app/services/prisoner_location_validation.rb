class PrisonerLocationValidation
  INVALID = 'location_invalid'.freeze
  UNKNOWN = 'location_unknown'.freeze

  include ActiveModel::Model

  validate :located_at_given_prison
  validate :validate_has_location

  def initialize(offender, prison_code = nil)
    self.offender    = offender
    self.prison_code = prison_code
  end

  def internal_location
    establishment.housing_location if valid?
  end

private

  attr_accessor :offender, :prison_code

  def validate_has_location
    unless establishment.api_call_successful?
      errors.clear
      errors.add(:base, UNKNOWN)
    end
  end

  def establishment
    @establishment ||= load_establishment
  end

  def located_at_given_prison
    return if prison_code.nil?

    unless establishment.code == prison_code
      errors.add(:base, INVALID)
    end
  end

  def load_establishment
    return Nomis::Establishment.new unless offender.valid?
    Nomis::Api.instance.lookup_offender_location(noms_id: offender.noms_id)
  rescue Nomis::APIError => e
    Raven.capture_exception(
      e, fingerprint: %w[nomis lookup_offender_location_error])
    PVB::Instrumentation.append_to_log(lookup_offender_location: false)
    Nomis::Establishment.new(api_call_successful: false)
  end
end
