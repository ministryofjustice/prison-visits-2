require 'human_readable_id'

class BookingRequestCreator
  def create!(prisoner_step, visitors_step, slots_step, locale)
    create_visit(prisoner_step, visitors_step, slots_step, locale).tap { |visit|
      VisitorMailer.request_acknowledged(visit).deliver_later
    }
  end

private

  def create_visit(prisoner_step, visitors_step, slots_step, locale)
    ActiveRecord::Base.transaction do
      visit = build_visit(prisoner_step, visitors_step, slots_step, locale)
      visit.save!
      human_id = HumanReadableId.update_unique_id(Visit, visit.id, :human_id)
      visit.human_id = human_id
      create_visitors(visitors_step, visit)
      visit
    end
  end

  def build_visit(prisoner_step, visitors_step, slots_step, locale)
    Visit.new(
      prisoner_id: create_prisoner(prisoner_step).id,
      prison_id: prisoner_step.prison_id,
      contact_email_address: visitors_step.email_address,
      contact_phone_no: visitors_step.phone_no,
      slot_option_0: slots_step.option_0,
      slot_option_1: slots_step.option_1,
      slot_option_2: slots_step.option_2,
      locale: locale
    )
  end

  def create_visitors(visitors_step, visit)
    visitors_step.visitors.each_with_index do |visitor, sort_index|
      attributes = attributes_for_visitor(visitor)
      attributes[:sort_index] = sort_index
      if sort_index.zero?
        visit.create_lead_visitor!(attributes)
      else
        visit.visitors.create!(attributes)
      end
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

  def attributes_for_visitor(visitor)
    {
      first_name:    visitor.first_name,
      last_name:     visitor.last_name,
      date_of_birth: visitor.date_of_birth
    }
  end
end
