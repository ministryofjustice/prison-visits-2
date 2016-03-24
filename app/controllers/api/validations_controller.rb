module Api
  class ValidationsController < ApiController
    def prisoner
      valid = true
      errors = []

      offender = Nomis::Api.instance.lookup_active_offender(
        noms_id: params.fetch(:number),
        date_of_birth: Date.parse(params.fetch(:date_of_birth))
      )

      unless offender
        valid = false
        errors << 'prisoner_does_not_exist'
      end

      validation = { valid: valid }
      validation[:errors] = errors if errors.any?

      render status: 200, json: { validation: validation }
    end
  end
end
