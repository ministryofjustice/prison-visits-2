class BookingRequestCreator
  def create!(prisoner_step, visitors_step, slots_step)
    options = [
      prisoner_step_options(prisoner_step),
      visitors_step_options(visitors_step),
      slots_step_options(slots_step)
    ].inject(&:merge)

    Visit.create! options
  end

private

  def prisoner_step_options(step)
    {
      prison_id: step.prison_id,
      prisoner_first_name: step.first_name,
      prisoner_last_name: step.last_name,
      prisoner_date_of_birth: step.date_of_birth,
      prisoner_number: step.number
    }
  end

  def visitors_step_options(step)
    {
      visitor_first_name: step.first_name,
      visitor_last_name: step.last_name,
      visitor_date_of_birth: step.date_of_birth,
      visitor_email_address: step.email_address,
      visitor_phone_no: step.phone_no
    }
  end

  def slots_step_options(step)
    {
      slot_option_1: step.option_1,
      slot_option_2: step.option_2,
      slot_option_3: step.option_3
    }
  end
end
