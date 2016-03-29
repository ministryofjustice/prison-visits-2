class PrisonerValidation
  include NonPersistedModel

  attribute :noms_id, String
  attribute :date_of_birth, Date

  validate :active_offender_exists

  def active_offender_exists
    # Validation should pass if the Nomis API has been disabled
    return unless Nomis::Api.enabled?

    offender = Nomis::Api.instance.lookup_active_offender(
      noms_id: noms_id,
      date_of_birth: date_of_birth
    )

    unless offender
      errors.add :general, 'prisoner_does_not_exist'
    end
  rescue Excon::Errors::Error => e
    # Validation should pass if the Nomis API is misbehaving
    Rails.logger.warn "Error calling the nomis API: #{e.inspect}"
  end
end
