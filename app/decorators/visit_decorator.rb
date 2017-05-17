class VisitDecorator < Draper::Decorator
  delegate_all
  decorates_association :rejection

  delegate :prisoner_existance_status,
    :prisoner_existance_error,
    :prisoner_availability_unknown?,
    :slot_availability_unknown?,
    :slots_unavailable?,
    :contact_list_unknown?,
    :approved_contacts,
    to: :nomis_checker

  def slots
    @slots ||= object.slots.map.with_index { |slot, i|
      ConcreteSlotDecorator.decorate(
        slot,
        context: { index: i, visit: object, nomis_checker: nomis_checker }
      )
    }
  end

  def rejection
    @rejection ||= begin
                     if object.rejection
                       object.rejection.decorate
                     else
                       object.build_rejection.decorate.tap do |rej|
                         rej.apply_nomis_reasons(nomis_checker)
                       end
                     end
                   end
  end

  def principal_visitor
    @principal_visitor ||= object.principal_visitor.decorate
  end

  def additional_visitors
    @additional_visitors ||= VisitorDecorator.
                               decorate_collection(object.additional_visitors)
  end

  def processed_at
    @processed_at ||= last_visit_state_change&.created_at || object.created_at
  end

private

  def last_visit_state_change
    object.visit_state_changes.max_by(&:created_at)
  end

  def nomis_checker
    @nomis_checker ||= StaffNomisCheckerFactory.for(object)
  end
end
