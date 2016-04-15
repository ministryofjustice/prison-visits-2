module Api
  class ValidationsController < ApiController
    # rubocop:disable Metrics/MethodLength
    def prisoner
      begin
        date = Date.parse(params.fetch(:date_of_birth))
      rescue ArgumentError
        raise ParameterError, 'date_of_birth'
      end

      validation = PrisonerValidation.new(
        noms_id: params.fetch(:number),
        date_of_birth: date
      )

      if validation.valid?
        response = { valid: true }
      else
        response = { valid: false, errors: validation.errors.values.flatten }
      end

      render status: 200, json: { validation: response }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
