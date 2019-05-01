module Api
  class ValidationsController < ApiController
    def prisoner
      date, noms_id = validate_prisoner_parameters(params)

      checker = ApiPrisonerChecker.new(noms_id: noms_id, date_of_birth: date)

      validation = if checker.valid?
                     { valid: true }
                   else
                     { valid: false, errors: [checker.error] }
                   end

      render status: 200, json: { validation: validation }
    end

    def visitors
      lead_date_of_birth, dates_of_birth = validate_visitors_parameters(params)
      prison = validate_prison_id_parameter(params)

      visitors_group = VisitorsValidation.new(
        prison: prison,
        lead_date_of_birth: lead_date_of_birth,
        dates_of_birth: dates_of_birth)

      render status: 200, json: {
        validation: visitors_response(visitors_group)
      }
    end

  private

    def visitors_response(visitors_group)
      if visitors_group.valid?
        { valid: true }
      else
        { valid: false, errors: visitors_group.error_keys }
      end
    end

    def validate_visitors_parameters(params)
      lead_date_of_birth = validate_date(params.fetch(:lead_date_of_birth),
                                         :lead_date_of_birth)

      dates_of_birth = params.fetch(:dates_of_birth).map { |date|
        validate_date(date, :dates_of_birth)
      }

      [lead_date_of_birth, dates_of_birth]
    end

    def validate_prisoner_parameters(params)
      date = validate_date(params.fetch(:date_of_birth), :date_of_birth)

      noms_id = params.fetch(:number)

      [date, noms_id]
    end

    def validate_prison_id_parameter(params)
      Prison.find(params.fetch(:prison_id))
    rescue ActiveRecord::RecordNotFound
      raise ParameterError, 'prison_id'
    end

    def validate_date(value, field_name)
      Date.parse(value)
    rescue ArgumentError
      raise ParameterError, field_name
    end
  end
end
