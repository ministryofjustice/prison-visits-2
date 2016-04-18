module Api
  class ValidationsController < ApiController
    def prisoner
      date, noms_id = validate_prisoner_parameters(params)

      prisoner = PrisonerValidation.new(noms_id: noms_id, date_of_birth: date)

      if prisoner.valid?
        response = { valid: true }
      else
        response = { valid: false, errors: prisoner.errors.values.flatten }
      end

      render status: 200, json: { validation: response }
    end

  private

    def validate_prisoner_parameters(params)
      begin
        date = Date.parse(params.fetch(:date_of_birth))
      rescue ArgumentError
        raise ParameterError, 'date_of_birth'
      end

      noms_id = params.fetch(:number)

      # TODO: Discuss removing this cop; especially when there are multiple
      # return values I find an explicit return much cleaner.
      # rubocop:disable Style/RedundantReturn
      return date, noms_id
      # rubocop:enable Style/RedundantReturn
    end
  end
end
