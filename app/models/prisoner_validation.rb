class PrisonerValidation
  include NonPersistedModel

  UNKNOWN = 'unknown'.freeze
  PRISONER_NOT_EXIST = 'prisoner_does_not_exist'.freeze

  attribute :noms_id, String
  attribute :date_of_birth, Date

  validate :active_offender_exists

  def active_offender_exists
    unless Nomis::Api.enabled?
      errors.add :base, UNKNOWN
      return
    end

    return if offender

    if @offender_api_error
      errors.add :base, UNKNOWN
    else
      errors.add :base, PRISONER_NOT_EXIST
    end
  end

  def offender
    @offender ||= load_offender
  end

private

  def load_offender
    return nil if @offender_api_error

    Nomis::Api.instance.lookup_active_offender(
      noms_id: noms_id, date_of_birth: date_of_birth)
  rescue Excon::Errors::Error => e
    @offender_api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end
end
