class BookingRequestCreator
  def create!(prisoner_step, visitors_step, slots_step)
    params = build_params(prisoner_step, visitors_step, slots_step)
    Visit.create!(params).tap { |visit|
      PrisonMailer.request_received(visit).deliver_later
      add_log_metadata visit_id: visit.id
    }
  end

private

  def add_log_metadata(hash)
    LogStasher.request_context.merge!(hash)
  end

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
      visitor_email_address: step.email_address,
      visitor_phone_no: step.phone_no
    }
  end

  def slots_step_params(step)
    {
      slot_option_1: step.option_1,
      slot_option_2: step.option_2,
      slot_option_3: step.option_3
    }
  end
end
