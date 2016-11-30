class ApiPrisonerChecker
  def initialize(noms_id:, date_of_birth:)
    @offender = if Nomis::Api.enabled?
                  Nomis::Api.instance.lookup_active_offender(
                    noms_id:       noms_id,
                    date_of_birth: date_of_birth
                  )
                else
                  Nomis::NullOffender.new(api_call_successful: false)
                end
  end

  def valid?
    error.nil? || error == PrisonerValidation::UNKNOWN
  end

  def error
    prisoner_validation.errors[:base].first
  end

private

  def prisoner_validation
    @prisoner_validation ||= PrisonerValidation.new(@offender).tap(&:valid?)
  end
end
