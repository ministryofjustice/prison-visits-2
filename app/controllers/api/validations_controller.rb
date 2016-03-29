module Api
  class ValidationsController < ApiController
    def prisoner
      validation = PrisonerValidation.new(
        noms_id: params.fetch(:number),
        date_of_birth: Date.parse(params.fetch(:date_of_birth))
      )

      if validation.valid?
        response = { valid: true }
      else
        response = { valid: false, errors: validation.errors.values.flatten }
      end

      render status: 200, json: { validation: response }
    end
  end
end
