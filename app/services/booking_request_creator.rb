class BookingRequestCreator
  def create!(prisoner_step, visitors_step, slots_step)
    params = build_params(prisoner_step, visitors_step, slots_step)
    Visit.create!(params).tap { |visit|
      VisitorMailer.request_acknowledged(visit).deliver_later
      PrisonMailer.request_received(visit).deliver_later
      LoggerMetadata.add visit_id: visit.id
    }
  end

private

  def build_params(prisoner_step, visitors_step, slots_step)
    [
      prisoner_step_params(prisoner_step),
      visitors_step_params(visitors_step),
      slots_step_params(slots_step)
    ].inject(&:merge)
  end

  def prisoner_step_params(step)
    {
      prison_id: step.prison_id,
      prisoner_first_name: step.first_name,
      prisoner_last_name: step.last_name,
      prisoner_date_of_birth: step.date_of_birth,
      prisoner_number: step.number
    }
  end

  def visitors_step_params(step)
    {
      visitor_first_name: step.first_name,
      visitor_last_name: step.last_name,
      visitor_date_of_birth: step.date_of_birth,
      contact_email_address: step.email_address,
      contact_phone_no: step.phone_no,
      override_delivery_error: step.override_delivery_error,
      delivery_error_type: step.delivery_error_type
    }
  end

  def slots_step_params(step)
    {
      slot_option_0: step.option_0,
      slot_option_1: step.option_1,
      slot_option_2: step.option_2
    }
  end
end
