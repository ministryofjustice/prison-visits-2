class VisitDecorator < Draper::Decorator
  delegate_all
  decorates_association :rejection

  delegate :prisoner_existance_status,
    :prisoner_existance_error,
    :prisoner_availability_unknown?,
    :slot_availability_unknown?,
    :slots_unavailable?,
    to: :nomis_checker

  def prisoner_details_incorrect?
    (
      object.rejection &&
      object.rejection.reasons.include?(Rejection::PRISONER_DETAILS_INCORRECT)
    ) || prisoner_existance_status == StaffNomisChecker::INVALID
  end

  def slots
    @slots ||= object.slots.map.with_index { |slot, i|
      ConcreteSlotDecorator.decorate(
        slot,
        context: { index: i, nomis_checker: nomis_checker }
      )
    }
  end

  def rejection
    return @rejection if @rejection
    return @rejection = object.rejection.decorate if object.rejection

    @rejection = object.build_rejection.decorate.tap do |rej|
      rej.apply_nomis_reasons(self, nomis_checker)
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
