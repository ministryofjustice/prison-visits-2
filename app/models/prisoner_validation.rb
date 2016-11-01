# frozen_string_literal: true
class PrisonerValidation
  include NonPersistedModel

  UNKNOWN = 'unknown'
  PRISONER_NOT_EXIST = 'prisoner_does_not_exist'

  attribute :noms_id, String
  attribute :date_of_birth, Date

  validate :active_offender_exists

  def active_offender_exists
    if Nomis::Api.enabled?
      offender = Nomis::Api.instance.lookup_active_offender(
        noms_id: noms_id, date_of_birth: date_of_birth
      )

      errors.add :base, PRISONER_NOT_EXIST unless offender
    else
      errors.add :base, UNKNOWN
    end
  rescue Excon::Errors::Error => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    errors.add :base, UNKNOWN
  end
end
