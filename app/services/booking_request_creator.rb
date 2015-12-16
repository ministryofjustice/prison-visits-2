class BookingRequestCreator
  def create!(prisoner_step, visitors_step, slots_step)
    create_visit(prisoner_step, visitors_step, slots_step).tap { |visit|
      VisitorMailer.request_acknowledged(visit).deliver_later
      PrisonMailer.request_received(visit).deliver_later
      LoggerMetadata.add visit_id: visit.id
    }
  end

private

  # rubocop:disable Metrics/MethodLength
  def create_visit(prisoner_step, visitors_step, slots_step)
    Visit.create!(
      prisoner_id: create_prisoner(prisoner_step).id,
      prison_id: prisoner_step.prison_id,
      contact_email_address: visitors_step.email_address,
      contact_phone_no: visitors_step.phone_no,
      override_delivery_error: visitors_step.override_delivery_error,
      delivery_error_type: visitors_step.delivery_error_type,
      slot_option_0: slots_step.option_0,
      slot_option_1: slots_step.option_1,
      slot_option_2: slots_step.option_2
    ).tap { |v| create_visitors visitors_step, v }
  end
  # rubocop:enable Metrics/MethodLength

  def create_visitors(visitors_step, visit)
    visitors_step.visitors.each_with_index do |visitor, sort_index|
      visit.visitors.create!(
        first_name: visitor.first_name,
        last_name: visitor.last_name,
        date_of_birth: visitor.date_of_birth,
        sort_index: sort_index
      )
    end
  end

  def create_prisoner(prisoner_step)
    Prisoner.create!(
      first_name: prisoner_step.first_name,
      last_name: prisoner_step.last_name,
      date_of_birth: prisoner_step.date_of_birth,
      number: prisoner_step.number
    )
  end
end
