class PrisonerLocationValidation
  INVALID = 'location_invalid'.freeze
  UNKNOWN = 'location_unknown'.freeze

  include ActiveModel::Model

  validate :located_at_given_prison
  validate :validate_has_location

  def initialize(prisoner, prison_code = nil)
    self.prisoner    = prisoner
    self.prison_code = prison_code
  end

  def internal_location
    establishment.housing_location.description if valid?
  end

private

  attr_accessor :prisoner, :prison_code

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
    return Nomis::Establishment.new unless prisoner.valid?
    Nomis::Api.instance.lookup_prisoner_location(noms_id: prisoner.noms_id)
  rescue Nomis::APIError => e
    PVB::ExceptionHandler.capture_exception(
      e, fingerprint: %w[nomis lookup_prisoner_location_error])
    PVB::Instrumentation.append_to_log(lookup_prisoner_location: false)
    Nomis::Establishment.new(api_call_successful: false)
  end
end
