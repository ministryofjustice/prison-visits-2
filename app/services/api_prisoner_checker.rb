class ApiPrisonerChecker
  def initialize(noms_id:, date_of_birth:)
    @noms_id = noms_id
    @date_of_birth = date_of_birth
  end

  def valid?
    error.nil? || error == PrisonerValidation::UNKNOWN
  end

  def error
    prisoner_validation.errors[:base].first
  end

private

  def prisoner_validation
    @prisoner_validation ||=
      PrisonerValidation.
      new(noms_id: @noms_id, date_of_birth: @date_of_birth).tap(&:valid?)
  end
end
