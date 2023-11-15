class ApiPrisonerChecker
  def initialize(noms_id:, date_of_birth:)
    @prisoner = if Nomis::Api.enabled?
                  Nomis::Api.instance.lookup_active_prisoner(
                    noms_id:,
                    date_of_birth:
                  )
                else
                  Nomis::NullPrisoner.new(api_call_successful: false)
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
    @prisoner_validation ||= PrisonerValidation.new(@prisoner).tap(&:valid?)
  end
end
